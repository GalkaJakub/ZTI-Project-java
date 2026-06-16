package wsp.repository;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.MealPlan;
import wsp.entity.UserGroup;

import java.time.LocalDate;
import java.util.Optional;

/**
 * Repozytorium tygodniowych planów posiłków.
 */
public interface MealPlanRepository extends JpaRepository<MealPlan, Long> {

    /**
     * Wyszukuje plan grupy dla konkretnego początku tygodnia razem z posiłkami i przepisami.
     *
     * @param group grupa właścicielska planu
     * @param weekStartDate data poniedziałku rozpoczynającego tydzień
     * @return plan posiłków, jeśli istnieje
     */
    @EntityGraph(attributePaths = {"meals", "meals.recipe"})
    Optional<MealPlan> findByGroupAndWeekStartDate(UserGroup group, LocalDate weekStartDate);
}
