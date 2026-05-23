package wsp.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateShoppingItemRequest(
        @NotBlank(message = "Name cannot be blank")
        String name,

        @NotBlank(message = "Quantity cannot be blank")
        String quantity
)
{
}
