package wsp.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import wsp.dto.GroupMemberResponse;
import wsp.dto.GroupResponse;
import wsp.entity.AppUser;
import wsp.entity.GroupMember;
import wsp.entity.GroupRole;
import wsp.entity.UserGroup;
import wsp.repository.GroupMemberRepository;
import wsp.repository.UserGroupRepository;
import wsp.repository.UserRepository;

import java.security.SecureRandom;
import java.util.List;

/**
 * Serwis zarządzający grupami użytkowników, członkostwem i kodami zaproszeń.
 */
@Service
public class GroupService {

    private static final String INVITE_CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final int INVITE_CODE_LENGTH = 8;

    private final UserGroupRepository userGroupRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final UserRepository userRepository;
    private final SecureRandom secureRandom = new SecureRandom();

    /**
     * Tworzy serwis grup z repozytoriami grup, członkostw i użytkowników.
     *
     * @param userGroupRepository repozytorium grup użytkowników
     * @param groupMemberRepository repozytorium członkostw w grupach
     * @param userRepository repozytorium użytkowników
     */
    public GroupService(
            UserGroupRepository userGroupRepository,
            GroupMemberRepository groupMemberRepository,
            UserRepository userRepository
    ) {
        this.userGroupRepository = userGroupRepository;
        this.groupMemberRepository = groupMemberRepository;
        this.userRepository = userRepository;
    }

    /**
     * Pobiera grupy, do których należy użytkownik.
     *
     * @param email adres e-mail użytkownika
     * @return lista grup użytkownika
     */
    public List<GroupResponse> getCurrentUserGroups(String email) {
        AppUser user = findUser(email);

        return groupMemberRepository.findByUserOrderByJoinedAtDesc(user).stream()
                .map(member -> GroupResponse.fromMembership(
                        member,
                        groupMemberRepository.countByGroup(member.getGroup())
                ))
                .toList();
    }

    /**
     * Tworzy nową grupę i nadaje użytkownikowi rolę właściciela.
     *
     * @param email adres e-mail użytkownika tworzącego grupę
     * @param name nazwa grupy
     * @return dane utworzonej grupy
     */
    @Transactional
    public GroupResponse createGroup(String email, String name) {
        AppUser user = findUser(email);

        UserGroup group = new UserGroup();
        group.setName(name.trim());
        group.setInviteCode(generateInviteCode());
        UserGroup savedGroup = userGroupRepository.save(group);

        GroupMember owner = new GroupMember();
        owner.setGroup(savedGroup);
        owner.setUser(user);
        owner.setRole(GroupRole.OWNER);
        GroupMember savedMember = groupMemberRepository.save(owner);

        return GroupResponse.fromMembership(savedMember, 1);
    }

    /**
     * Dołącza użytkownika do grupy na podstawie kodu zaproszenia.
     *
     * @param email adres e-mail użytkownika
     * @param inviteCode kod zaproszenia do grupy
     * @return dane grupy, do której użytkownik dołączył
     */
    @Transactional
    public GroupResponse joinGroup(String email, String inviteCode) {
        AppUser user = findUser(email);
        UserGroup group = userGroupRepository.findByInviteCodeIgnoreCase(inviteCode.trim())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Group invite code not found"));

        if (groupMemberRepository.existsByGroupAndUser(group, user)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "User already belongs to this group");
        }

        GroupMember member = new GroupMember();
        member.setGroup(group);
        member.setUser(user);
        member.setRole(GroupRole.MEMBER);
        GroupMember savedMember = groupMemberRepository.save(member);

        return GroupResponse.fromMembership(savedMember, groupMemberRepository.countByGroup(group));
    }

    /**
     * Pobiera członków grupy po sprawdzeniu, czy użytkownik ma do niej dostęp.
     *
     * @param email adres e-mail użytkownika wykonującego operację
     * @param groupId identyfikator grupy
     * @return lista członków grupy
     */
    public List<GroupMemberResponse> getMembers(String email, Long groupId) {
        AppUser user = findUser(email);
        UserGroup group = findGroup(groupId);
        requireMembership(group, user);

        return groupMemberRepository.findByGroupOrderByJoinedAtAsc(group).stream()
                .map(GroupMemberResponse::fromEntity).toList();
    }

    /**
     * Usuwa użytkownika z grupy z uwzględnieniem reguły właściciela.
     *
     * @param email adres e-mail użytkownika opuszczającego grupę
     * @param groupId identyfikator grupy
     */
    @Transactional
    public void leaveGroup(String email, Long groupId) {
        AppUser user = findUser(email);
        UserGroup group = findGroup(groupId);
        GroupMember membership = requireMembership(group, user);

        long memberCount = groupMemberRepository.countByGroup(group);
        if (membership.getRole() == GroupRole.OWNER && memberCount > 1) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Owner cannot leave a group with other members");
        }

        groupMemberRepository.delete(membership);

        if (memberCount == 1) {
            userGroupRepository.delete(group);
        }
    }

    private GroupMember requireMembership(UserGroup group, AppUser user) {
        return groupMemberRepository.findByGroupAndUser(group, user)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "User does not belong to this group"));
    }

    private UserGroup findGroup(Long groupId) {
        return userGroupRepository.findById(groupId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Group not found"));
    }

    private AppUser findUser(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }

    private String generateInviteCode() {
        String code;

        do {
            StringBuilder builder = new StringBuilder(INVITE_CODE_LENGTH);
            for (int i = 0; i < INVITE_CODE_LENGTH; i++) {
                builder.append(INVITE_CODE_CHARS.charAt(secureRandom.nextInt(INVITE_CODE_CHARS.length())));
            }
            code = builder.toString();
        } while (userGroupRepository.existsByInviteCode(code));

        return code;
    }
}
