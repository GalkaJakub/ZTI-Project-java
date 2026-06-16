package wsp.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Żądanie rejestracji nowego użytkownika.
 *
 * @param email adres e-mail nowego użytkownika
 * @param password hasło nowego użytkownika
 * @param displayName nazwa wyświetlana użytkownika
 */
public record RegisterRequest(
        @NotBlank(message = "Email cannot be blank")
        @Email(message = "Email must be valid")
        String email,

        @NotBlank(message = "Password cannot be blank")
        @Size(min = 8, max = 72, message = "Password must contain between 8 and 72 characters")
        String password,

        @NotBlank(message = "Display name cannot be blank")
        @Size(max = 40, message = "Display name cannot be longer than 40 characters")
        String displayName
) {
}
