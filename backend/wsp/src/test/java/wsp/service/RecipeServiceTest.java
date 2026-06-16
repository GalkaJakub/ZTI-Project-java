package wsp.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import wsp.ServiceIntegrationTestSupport;
import wsp.dto.CreatePlannedMealRequest;
import wsp.dto.CreateRecipeIngredientRequest;
import wsp.dto.CreateRecipeRequest;
import wsp.entity.MealType;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class RecipeServiceTest extends ServiceIntegrationTestSupport {

    @Autowired
    private RecipeService recipeService;

    @Autowired
    private MealPlanService mealPlanService;

    @Test
    void createsRecipeWithIngredientsAndReplacesThemOnUpdate() {
        TestMembership membership = createMembership("recipe");

        var createdRecipe = recipeService.create(
                membership.user().getEmail(),
                membership.group().getId(),
                new CreateRecipeRequest(
                        "  Nalesniki  ",
                        "  Szybkie sniadanie  ",
                        "  Wymieszaj i usmaz.  ",
                        List.of(
                                new CreateRecipeIngredientRequest("Maka", "200 g"),
                                new CreateRecipeIngredientRequest("Mleko", "300 ml")
                        )
                )
        );

        assertThat(createdRecipe.id()).isNotNull();
        assertThat(createdRecipe.title()).isEqualTo("Nalesniki");
        assertThat(createdRecipe.description()).isEqualTo("Szybkie sniadanie");
        assertThat(createdRecipe.instructions()).isEqualTo("Wymieszaj i usmaz.");
        assertThat(createdRecipe.ingredients()).extracting("name").containsExactly("Maka", "Mleko");

        var updatedRecipe = recipeService.update(
                membership.user().getEmail(),
                membership.group().getId(),
                createdRecipe.id(),
                new CreateRecipeRequest(
                        "Nalesniki na slono",
                        null,
                        "Usmaz i dodaj farsz.",
                        List.of(new CreateRecipeIngredientRequest("Ser", "100 g"))
                )
        );

        assertThat(updatedRecipe.title()).isEqualTo("Nalesniki na slono");
        assertThat(updatedRecipe.description()).isNull();
        assertThat(updatedRecipe.ingredients()).extracting("name").containsExactly("Ser");
    }

    @Test
    void deletesRecipeAndRejectsReadingMissingRecipe() {
        TestMembership membership = createMembership("recipe");
        var recipe = recipeService.create(
                membership.user().getEmail(),
                membership.group().getId(),
                new CreateRecipeRequest("Zupa", null, "Gotuj.", List.of())
        );

        recipeService.delete(membership.user().getEmail(), membership.group().getId(), recipe.id());

        assertThat(recipeRepository.existsById(recipe.id())).isFalse();
        assertThatThrownBy(() -> recipeService.getById(membership.user().getEmail(), membership.group().getId(), recipe.id()))
                .isInstanceOfSatisfying(ResponseStatusException.class, exception ->
                        assertThat(exception.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND));
    }

    @Test
    void deletesRecipeUsedByPlannedMealAndKeepsMealInPlan() {
        TestMembership membership = createMembership("recipe");
        LocalDate monday = LocalDate.of(2026, 6, 15);
        var recipe = recipeService.create(
                membership.user().getEmail(),
                membership.group().getId(),
                new CreateRecipeRequest("Makaron", null, "Gotuj.", List.of())
        );
        var meal = mealPlanService.createMeal(
                membership.user().getEmail(),
                membership.group().getId(),
                monday,
                new CreatePlannedMealRequest(monday, MealType.DINNER, "Obiad", null, recipe.id())
        );

        recipeService.delete(membership.user().getEmail(), membership.group().getId(), recipe.id());

        assertThat(recipeRepository.existsById(recipe.id())).isFalse();

        var weekPlan = mealPlanService.getWeekPlan(membership.user().getEmail(), membership.group().getId(), monday);
        assertThat(weekPlan.meals()).singleElement().satisfies(plannedMeal -> {
            assertThat(plannedMeal.id()).isEqualTo(meal.id());
            assertThat(plannedMeal.recipeId()).isNull();
            assertThat(plannedMeal.recipeTitle()).isNull();
        });
    }
}
