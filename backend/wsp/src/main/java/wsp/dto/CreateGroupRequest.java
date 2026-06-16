package wsp.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Żądanie utworzenia nowej grupy użytkowników.
 *
 * @param name nazwa tworzonej grupy
 */
public record CreateGroupRequest(
        @NotBlank(message = "Group name cannot be blank")
        @Size(max = 100, message = "Group name cannot be longer than 100 characters")
        String name
) {
}
