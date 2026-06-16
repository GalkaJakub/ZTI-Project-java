package wsp.dto;

import wsp.entity.MealType;
import wsp.entity.PlannedMeal;
import wsp.entity.Recipe;

import java.time.LocalDate;

/**
 * Odpowiedź opisująca pojedynczy zaplanowany posiłek.
 *
 * @param id identyfikator zaplanowanego posiłku
 * @param mealDate data posiłku
 * @param mealType typ posiłku
 * @param title nazwa posiłku
 * @param notes opcjonalne notatki
 * @param recipeId opcjonalny identyfikator powiązanego przepisu
 * @param recipeTitle opcjonalny tytuł powiązanego przepisu
 */
public record PlannedMealResponse(
        Long id,
        LocalDate mealDate,
        MealType mealType,
        String title,
        String notes,
        Long recipeId,
        String recipeTitle
) {

    /**
     * Tworzy DTO zaplanowanego posiłku na podstawie encji JPA.
     *
     * @param meal encja zaplanowanego posiłku
     * @return odpowiedź z danymi posiłku i opcjonalnym przepisem
     */
    public static PlannedMealResponse fromEntity(PlannedMeal meal) {
        Recipe recipe = meal.getRecipe();
        return new PlannedMealResponse(
                meal.getId(),
                meal.getMealDate(),
                meal.getMealType(),
                meal.getTitle(),
                meal.getNotes(),
                recipe == null ? null : recipe.getId(),
                recipe == null ? null : recipe.getTitle()
        );
    }
}
