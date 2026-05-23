package wsp.dto;

import wsp.entity.GroupMember;
import wsp.entity.GroupRole;

public record GroupResponse(
        Long id,
        String name,
        String inviteCode,
        GroupRole role,
        long memberCount
) {

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
