package wsp.controller;

import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import wsp.dto.CreatePlannedMealRequest;
import wsp.dto.MealPlanResponse;
import wsp.dto.PlannedMealResponse;
import wsp.service.MealPlanService;

import java.time.LocalDate;

/**
 * Kontroler REST obsługujący tygodniowe plany posiłków grup.
 */
@RestController
@RequestMapping("/api/groups/{groupId}/meal-plans/{dateInWeek}")
public class MealPlanController {

    private final MealPlanService mealPlanService;

    /**
     * Tworzy kontroler planów posiłków.
     *
     * @param mealPlanService serwis obsługujący tygodniowe plany posiłków
     */
    public MealPlanController(MealPlanService mealPlanService) {
        this.mealPlanService = mealPlanService;
    }

    /**
     * Zwraca tygodniowy plan posiłków dla tygodnia zawierającego podaną datę.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param dateInWeek dowolna data z wybranego tygodnia
     * @return tygodniowy plan posiłków
     */
    @GetMapping
    public MealPlanResponse getWeekPlan(Authentication authentication,
                                        @PathVariable Long groupId,
                                        @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateInWeek) {
        return mealPlanService.getWeekPlan(authentication.getName(), groupId, dateInWeek);
    }

    /**
     * Dodaje posiłek do wybranego tygodniowego planu.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param dateInWeek dowolna data z wybranego tygodnia
     * @param request dane posiłku
     * @return utworzony zaplanowany posiłek
     */
    @PostMapping("/meals")
    public PlannedMealResponse createMeal(Authentication authentication,
                                          @PathVariable Long groupId,
                                          @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateInWeek,
                                          @Valid @RequestBody CreatePlannedMealRequest request) {
        return mealPlanService.createMeal(authentication.getName(), groupId, dateInWeek, request);
    }

    /**
     * Aktualizuje istniejący posiłek w wybranym tygodniowym planie.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param dateInWeek dowolna data z wybranego tygodnia
     * @param mealId identyfikator zaplanowanego posiłku
     * @param request zaktualizowane dane posiłku
     * @return zaktualizowany zaplanowany posiłek
     */
    @PutMapping("/meals/{mealId}")
    public PlannedMealResponse updateMeal(Authentication authentication,
                                          @PathVariable Long groupId,
                                          @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateInWeek,
                                          @PathVariable Long mealId,
                                          @Valid @RequestBody CreatePlannedMealRequest request) {
        return mealPlanService.updateMeal(authentication.getName(), groupId, dateInWeek, mealId, request);
    }

    /**
     * Usuwa posiłek z wybranego tygodniowego planu.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param dateInWeek dowolna data z wybranego tygodnia
     * @param mealId identyfikator zaplanowanego posiłku
     */
    @DeleteMapping("/meals/{mealId}")
    public void deleteMeal(Authentication authentication,
                           @PathVariable Long groupId,
                           @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateInWeek,
                           @PathVariable Long mealId) {
        mealPlanService.deleteMeal(authentication.getName(), groupId, dateInWeek, mealId);
    }
}
