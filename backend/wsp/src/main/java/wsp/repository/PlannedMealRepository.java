package wsp.repository;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.MealPlan;
import wsp.entity.PlannedMeal;

import java.util.Optional;

public interface PlannedMealRepository extends JpaRepository<PlannedMeal, Long> {

    @EntityGraph(attributePaths = "recipe")
    Optional<PlannedMeal> findByIdAndMealPlan(Long id, MealPlan mealPlan);
}
