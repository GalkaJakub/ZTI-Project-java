package wsp.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;

import java.util.List;

public record CreateRecipeRequest(
        @NotBlank(message = "Title cannot be blank")
        String title,

        String description,

        @NotBlank(message = "Instructions cannot be blank")
        String instructions,

        List<@Valid CreateRecipeIngredientRequest> ingredients
) {
}
