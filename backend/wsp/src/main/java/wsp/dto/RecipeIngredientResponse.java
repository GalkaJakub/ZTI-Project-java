package wsp.dto;

import wsp.entity.RecipeIngredient;

/**
 * Odpowiedź opisująca składnik przepisu.
 *
 * @param id identyfikator składnika
 * @param name nazwa składnika
 * @param quantity ilość składnika
 */
public record RecipeIngredientResponse(
        Long id,
        String name,
        String quantity
) {

    /**
     * Tworzy DTO składnika przepisu z encji JPA.
     *
     * @param ingredient encja składnika
     * @return odpowiedź ze składnikiem przepisu
     */
    public static RecipeIngredientResponse fromEntity(RecipeIngredient ingredient) {
        return new RecipeIngredientResponse(
                ingredient.getId(),
                ingredient.getName(),
                ingredient.getQuantity()
        );
    }
}
