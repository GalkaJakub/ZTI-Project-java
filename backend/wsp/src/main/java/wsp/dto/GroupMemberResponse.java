package wsp.dto;

import wsp.entity.GroupMember;
import wsp.entity.GroupRole;

import java.time.LocalDateTime;

public record GroupMemberResponse(
        Long id,
        Long userId,
        String displayName,
        String email,
        GroupRole role,
        LocalDateTime joinedAt
) {

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
