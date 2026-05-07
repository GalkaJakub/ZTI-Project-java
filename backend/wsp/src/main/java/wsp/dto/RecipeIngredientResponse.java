package wsp.dto;

import wsp.entity.RecipeIngredient;

public record RecipeIngredientResponse(
        Long id,
        String name,
        String quantity
) {

    public static RecipeIngredientResponse fromEntity(RecipeIngredient ingredient) {
        return new RecipeIngredientResponse(
                ingredient.getId(),
                ingredient.getName(),
                ingredient.getQuantity()
        );
    }
}
