package wsp.dto;

/**
 * Odpowiedź zwracana po poprawnym logowaniu lub rejestracji.
 *
 * @param tokenType typ tokena zwracany klientowi, zwykle {@code Bearer}
 * @param accessToken token JWT używany w kolejnych żądaniach
 * @param user dane zalogowanego użytkownika
 */
public record AuthResponse(
        String tokenType,
        String accessToken,
        UserResponse user
) {
}
