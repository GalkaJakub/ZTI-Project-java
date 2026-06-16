package wsp.repository;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.MealPlan;
import wsp.entity.PlannedMeal;
import wsp.entity.Recipe;

import java.util.List;
import java.util.Optional;

/**
 * Repozytorium zaplanowanych posiłków w tygodniowych planach.
 */
public interface PlannedMealRepository extends JpaRepository<PlannedMeal, Long> {

    /**
     * Wyszukuje posiłek w konkretnym planie razem z opcjonalnym przepisem.
     *
     * @param id identyfikator posiłku
     * @param mealPlan plan posiłków
     * @return zaplanowany posiłek, jeśli istnieje w danym planie
     */
    @EntityGraph(attributePaths = "recipe")
    Optional<PlannedMeal> findByIdAndMealPlan(Long id, MealPlan mealPlan);

    /**
     * Pobiera posiłki powiązane z przepisem.
     *
     * @param recipe przepis
     * @return lista posiłków używających przepisu
     */
    List<PlannedMeal> findByRecipe(Recipe recipe);
}
