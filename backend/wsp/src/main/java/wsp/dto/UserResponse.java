package wsp.dto;

import wsp.entity.AppUser;

public record UserResponse(
        Long id,
        String email,
        String displayName
) {

    public static UserResponse fromEntity(AppUser user) {
        return new UserResponse(
                user.getId(),
                user.getEmail(),
                user.getDisplayName()
        );
    }
}
