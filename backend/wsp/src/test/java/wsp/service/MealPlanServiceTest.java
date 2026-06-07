package wsp.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import wsp.ServiceIntegrationTestSupport;
import wsp.dto.CreatePlannedMealRequest;
import wsp.dto.CreateRecipeRequest;
import wsp.entity.MealType;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class MealPlanServiceTest extends ServiceIntegrationTestSupport {

    @Autowired
    private MealPlanService mealPlanService;

    @Autowired
    private RecipeService recipeService;

    @Test
    void createsWeekPlanMealWithRecipeAndDeletesIt() {
        TestMembership membership = createMembership("meal");
        LocalDate monday = LocalDate.of(2026, 5, 25);
        LocalDate wednesday = monday.plusDays(2);
        var recipe = recipeService.create(
                membership.user().getEmail(),
                membership.group().getId(),
                new CreateRecipeRequest("Makaron", null, "Ugotuj.", List.of())
        );

        var createdMeal = mealPlanService.createMeal(
                membership.user().getEmail(),
                membership.group().getId(),
                wednesday,
                new CreatePlannedMealRequest(wednesday, MealType.DINNER, "Obiad", "bez miesa", recipe.id())
        );

        assertThat(createdMeal.id()).isNotNull();
        assertThat(createdMeal.mealDate()).isEqualTo(wednesday);
        assertThat(createdMeal.mealType()).isEqualTo(MealType.DINNER);
        assertThat(createdMeal.recipeId()).isEqualTo(recipe.id());
        assertThat(createdMeal.recipeTitle()).isEqualTo("Makaron");

        var weekPlan = mealPlanService.getWeekPlan(membership.user().getEmail(), membership.group().getId(), wednesday);
        assertThat(weekPlan.weekStartDate()).isEqualTo(monday);
        assertThat(weekPlan.meals()).singleElement().satisfies(meal ->
                assertThat(meal.id()).isEqualTo(createdMeal.id()));

        mealPlanService.deleteMeal(membership.user().getEmail(), membership.group().getId(), wednesday, createdMeal.id());

        assertThat(plannedMealRepository.existsById(createdMeal.id())).isFalse();
        assertThat(mealPlanService.getWeekPlan(membership.user().getEmail(), membership.group().getId(), wednesday).meals())
                .isEmpty();
    }

    @Test
    void rejectsMealDateOutsideSelectedWeek() {
        TestMembership membership = createMembership("meal");
        LocalDate monday = LocalDate.of(2026, 5, 25);

        assertThatThrownBy(() -> mealPlanService.createMeal(
                membership.user().getEmail(),
                membership.group().getId(),
                monday,
                new CreatePlannedMealRequest(monday.plusDays(7), MealType.DINNER, "Obiad", null, null)
        )).isInstanceOfSatisfying(ResponseStatusException.class, exception ->
                assertThat(exception.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST));
    }
}
