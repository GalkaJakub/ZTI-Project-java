package wsp.repository;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.MealPlan;
import wsp.entity.UserGroup;

import java.time.LocalDate;
import java.util.Optional;

public interface MealPlanRepository extends JpaRepository<MealPlan, Long> {

    @EntityGraph(attributePaths = {"meals", "meals.recipe"})
    Optional<MealPlan> findByGroupAndWeekStartDate(UserGroup group, LocalDate weekStartDate);
}
