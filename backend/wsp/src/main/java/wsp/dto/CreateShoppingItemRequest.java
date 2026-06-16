package wsp.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * Żądanie dodania produktu do listy zakupów.
 *
 * @param name nazwa produktu
 * @param quantity ilość produktu do kupienia
 */
public record CreateShoppingItemRequest(
        @NotBlank(message = "Name cannot be blank")
        String name,

        @NotBlank(message = "Quantity cannot be blank")
        String quantity
)
{
}
