package wsp.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * Żądanie utworzenia składnika przepisu.
 *
 * @param name nazwa składnika
 * @param quantity ilość składnika w przepisie
 */
public record CreateRecipeIngredientRequest(
        @NotBlank(message = "Ingredient name cannot be blank")
        String name,

        @NotBlank(message = "Ingredient quantity cannot be blank")
        String quantity
) {
}
