package wsp.dto;

import wsp.entity.MealPlan;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;

/**
 * Odpowiedź opisująca tygodniowy plan posiłków grupy.
 *
 * @param id identyfikator planu posiłków
 * @param groupId identyfikator grupy, do której należy plan
 * @param weekStartDate data początku tygodnia planu
 * @param meals posortowana lista posiłków w planie
 */
public record MealPlanResponse(
        Long id,
        Long groupId,
        LocalDate weekStartDate,
        List<PlannedMealResponse> meals
) {

    /**
     * Tworzy DTO planu posiłków z encji JPA.
     *
     * @param mealPlan encja planu posiłków
     * @return odpowiedź z posortowanymi posiłkami
     */
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
