package wsp.dto;

import wsp.entity.GroupMember;
import wsp.entity.GroupRole;

import java.time.LocalDateTime;

/**
 * Odpowiedź opisująca członka grupy.
 *
 * @param id identyfikator członkostwa w grupie
 * @param userId identyfikator użytkownika
 * @param displayName nazwa wyświetlana użytkownika
 * @param email adres e-mail użytkownika
 * @param role rola użytkownika w grupie
 * @param joinedAt data dołączenia do grupy
 */
public record GroupMemberResponse(
        Long id,
        Long userId,
        String displayName,
        String email,
        GroupRole role,
        LocalDateTime joinedAt
) {

    /**
     * Tworzy DTO członka grupy na podstawie encji JPA.
     *
     * @param member encja członkostwa
     * @return odpowiedź z danymi członka grupy
     */
    public static GroupMemberResponse fromEntity(GroupMember member) {
        return new GroupMemberResponse(
                member.getId(),
                member.getUser().getId(),
                member.getUser().getDisplayName(),
                member.getUser().getEmail(),
                member.getRole(),
                member.getJoinedAt()
        );
    }
}
