package wsp.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * Żądanie dołączenia do grupy przy pomocy kodu zaproszenia.
 *
 * @param inviteCode kod zaproszenia wygenerowany dla grupy
 */
public record JoinGroupRequest(
        @NotBlank(message = "Invite code cannot be blank")
        String inviteCode
) {
}
