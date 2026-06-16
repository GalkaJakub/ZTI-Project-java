package wsp.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * Żądanie aktualizacji danych profilu użytkownika.
 *
 * @param displayName nowa nazwa wyświetlana użytkownika
 */
public record UpdateUserRequest(
        @NotBlank(message = "Display name cannot be blank")
        String displayName
) {
}
