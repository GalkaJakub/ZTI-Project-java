package wsp.dto;

import wsp.entity.GroupMember;
import wsp.entity.GroupRole;

/**
 * Odpowiedź opisująca grupę z perspektywy aktualnego użytkownika.
 *
 * @param id identyfikator grupy
 * @param name nazwa grupy
 * @param inviteCode kod zaproszenia do grupy
 * @param role rola aktualnego użytkownika w grupie
 * @param memberCount liczba członków grupy
 */
public record GroupResponse(
        Long id,
        String name,
        String inviteCode,
        GroupRole role,
        long memberCount
) {

    /**
     * Tworzy DTO grupy na podstawie członkostwa i liczby członków.
     *
     * @param membership członkostwo użytkownika w grupie
     * @param memberCount liczba członków grupy
     * @return odpowiedź z danymi grupy
     */
    public static GroupResponse fromMembership(GroupMember membership, long memberCount) {
        return new GroupResponse(
                membership.getGroup().getId(),
                membership.getGroup().getName(),
                membership.getGroup().getInviteCode(),
                membership.getRole(),
                memberCount
        );
    }
}
