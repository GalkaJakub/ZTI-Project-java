package wsp.dto;

import wsp.entity.MealType;
import wsp.entity.PlannedMeal;
import wsp.entity.Recipe;

import java.time.LocalDate;

public record PlannedMealResponse(
        Long id,
        LocalDate mealDate,
        MealType mealType,
        String title,
        String notes,
        Long recipeId,
        String recipeTitle
) {

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
