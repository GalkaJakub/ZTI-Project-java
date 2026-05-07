package wsp.dto;

import wsp.entity.Recipe;

import java.util.List;

public record RecipeResponse(
        Long id,
        String title,
        String description,
        String instructions,
        List<RecipeIngredientResponse> ingredients
) {

    public static RecipeResponse fromEntity(Recipe recipe) {
        return new RecipeResponse(
                recipe.getId(),
                recipe.getTitle(),
                recipe.getDescription(),
                recipe.getInstructions(),
                recipe.getIngredients().stream()
                        .map(RecipeIngredientResponse::fromEntity)
                        .toList()
        );
    }
}
