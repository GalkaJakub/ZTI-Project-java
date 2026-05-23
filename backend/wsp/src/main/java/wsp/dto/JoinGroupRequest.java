package wsp.dto;

import jakarta.validation.constraints.NotBlank;

public record JoinGroupRequest(
        @NotBlank(message = "Invite code cannot be blank")
        String inviteCode
) {
}
