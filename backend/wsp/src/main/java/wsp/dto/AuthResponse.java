package wsp.dto;

public record AuthResponse(
        String tokenType,
        String accessToken,
        UserResponse user
) {
}
