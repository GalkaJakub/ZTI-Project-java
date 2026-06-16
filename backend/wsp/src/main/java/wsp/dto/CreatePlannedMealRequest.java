package wsp.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import wsp.entity.MealType;

import java.time.LocalDate;

/**
 * Żądanie utworzenia lub aktualizacji zaplanowanego posiłku.
 *
 * @param mealDate data posiłku w obrębie wybranego tygodnia
 * @param mealType typ posiłku, np. śniadanie albo obiad
 * @param title nazwa posiłku widoczna w planie
 * @param notes opcjonalne notatki do posiłku
 * @param recipeId opcjonalny identyfikator powiązanego przepisu
 */
public record CreatePlannedMealRequest(
        @NotNull(message = "Meal date is required")
        LocalDate mealDate,

        @NotNull(message = "Meal type is required")
        MealType mealType,

        @NotBlank(message = "Title cannot be blank")
        String title,

        String notes,

        Long recipeId
) {
}
