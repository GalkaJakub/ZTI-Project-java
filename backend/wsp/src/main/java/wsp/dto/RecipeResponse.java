package wsp.dto;

import wsp.entity.Recipe;

import java.util.List;

/**
 * Odpowiedź opisująca przepis wraz ze składnikami.
 *
 * @param id identyfikator przepisu
 * @param groupId identyfikator grupy, do której należy przepis
 * @param title tytuł przepisu
 * @param description opcjonalny opis przepisu
 * @param instructions instrukcja przygotowania
 * @param ingredients składniki przepisu
 */
public record RecipeResponse(
        Long id,
        Long groupId,
        String title,
        String description,
        String instructions,
        List<RecipeIngredientResponse> ingredients
) {

    /**
     * Tworzy DTO przepisu na podstawie encji JPA.
     *
     * @param recipe encja przepisu
     * @return odpowiedź z przepisem i składnikami
     */
    public static RecipeResponse fromEntity(Recipe recipe) {
        return new RecipeResponse(
                recipe.getId(),
                recipe.getGroup().getId(),
                recipe.getTitle(),
                recipe.getDescription(),
                recipe.getInstructions(),
                recipe.getIngredients().stream()
                        .map(RecipeIngredientResponse::fromEntity)
                        .toList()
        );
    }
}
