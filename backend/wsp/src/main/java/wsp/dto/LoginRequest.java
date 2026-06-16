package wsp.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

/**
 * Żądanie logowania użytkownika.
 *
 * @param email adres e-mail użytkownika
 * @param password hasło użytkownika
 */
public record LoginRequest(
        @NotBlank(message = "Email cannot be blank")
        @Email(message = "Email must be valid")
        String email,

        @NotBlank(message = "Password cannot be blank")
        String password
) {
}
