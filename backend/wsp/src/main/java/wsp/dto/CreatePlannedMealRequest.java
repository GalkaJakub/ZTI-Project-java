package wsp.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import wsp.entity.MealType;

import java.time.LocalDate;

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
