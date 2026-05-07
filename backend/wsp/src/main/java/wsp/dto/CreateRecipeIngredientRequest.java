package wsp.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateRecipeIngredientRequest(
        @NotBlank(message = "Ingredient name cannot be blank")
        String name,

        @NotBlank(message = "Ingredient quantity cannot be blank")
        String quantity
) {
}
