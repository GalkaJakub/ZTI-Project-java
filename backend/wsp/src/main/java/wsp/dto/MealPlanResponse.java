package wsp.dto;

import wsp.entity.MealPlan;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;

public record MealPlanResponse(
        Long id,
        Long groupId,
        LocalDate weekStartDate,
        List<PlannedMealResponse> meals
) {

    public static MealPlanResponse fromEntity(MealPlan mealPlan) {
        return new MealPlanResponse(
                mealPlan.getId(),
                mealPlan.getGroup().getId(),
                mealPlan.getWeekStartDate(),
                mealPlan.getMeals().stream()
                        .sorted(Comparator
                                .comparing((wsp.entity.PlannedMeal meal) -> meal.getMealDate())
                                .thenComparing(meal -> meal.getMealType().ordinal()))
                        .map(PlannedMealResponse::fromEntity)
                        .toList()
        );
    }
}
