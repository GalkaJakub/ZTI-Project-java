package wsp.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import wsp.ServiceIntegrationTestSupport;
import wsp.entity.AppUser;
import wsp.entity.GroupRole;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class GroupServiceTest extends ServiceIntegrationTestSupport {

    @Autowired
    private GroupService groupService;

    @Test
    void createsGroupWithOwnerMembership() {
        AppUser user = createUser("owner");

        var createdGroup = groupService.createGroup(user.getEmail(), "  Dom  ");

        assertThat(createdGroup.id()).isNotNull();
        assertThat(createdGroup.name()).isEqualTo("Dom");
        assertThat(createdGroup.inviteCode()).hasSize(8);
        assertThat(createdGroup.role()).isEqualTo(GroupRole.OWNER);
        assertThat(createdGroup.memberCount()).isEqualTo(1);

        var memberships = groupMemberRepository.findByGroupOrderByJoinedAtAsc(
                userGroupRepository.findById(createdGroup.id()).orElseThrow()
        );
        assertThat(memberships)
                .singleElement()
                .satisfies(member -> {
                    assertThat(member.getUser().getEmail()).isEqualTo(user.getEmail());
                    assertThat(member.getRole()).isEqualTo(GroupRole.OWNER);
                });
    }

    @Test
    void joinsGroupByInviteCodeAndRejectsDuplicateMembership() {
        AppUser owner = createUser("owner");
        AppUser invitedUser = createUser("member");
        var group = groupService.createGroup(owner.getEmail(), "Rodzina");

        var joinedGroup = groupService.joinGroup(invitedUser.getEmail(), "  " + group.inviteCode().toLowerCase() + "  ");

        assertThat(joinedGroup.id()).isEqualTo(group.id());
        assertThat(joinedGroup.role()).isEqualTo(GroupRole.MEMBER);
        assertThat(joinedGroup.memberCount()).isEqualTo(2);

        assertThatThrownBy(() -> groupService.joinGroup(invitedUser.getEmail(), group.inviteCode()))
                .isInstanceOfSatisfying(ResponseStatusException.class, exception ->
                        assertThat(exception.getStatusCode()).isEqualTo(HttpStatus.CONFLICT));
    }

    @Test
    void preventsOwnerFromLeavingGroupWithOtherMembers() {
        AppUser owner = createUser("owner");
        AppUser member = createUser("member");
        var group = groupService.createGroup(owner.getEmail(), "Rodzina");
        groupService.joinGroup(member.getEmail(), group.inviteCode());

        assertThatThrownBy(() -> groupService.leaveGroup(owner.getEmail(), group.id()))
                .isInstanceOfSatisfying(ResponseStatusException.class, exception ->
                        assertThat(exception.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST));
    }
}
