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
 * REST controller for weekly group meal plans.
 */
@RestController
@RequestMapping("/api/groups/{groupId}/meal-plans/{dateInWeek}")
public class MealPlanController {

    private final MealPlanService mealPlanService;

    public MealPlanController(MealPlanService mealPlanService) {
        this.mealPlanService = mealPlanService;
    }

    /**
     * Returns a weekly meal plan for the week containing the provided date.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @param dateInWeek any date inside the requested week
     * @return weekly meal plan
     */
    @GetMapping
    public MealPlanResponse getWeekPlan(Authentication authentication,
                                        @PathVariable Long groupId,
                                        @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateInWeek) {
        return mealPlanService.getWeekPlan(authentication.getName(), groupId, dateInWeek);
    }

    /**
     * Adds a meal to the selected weekly plan.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @param dateInWeek any date inside the requested week
     * @param request meal data
     * @return created planned meal
     */
    @PostMapping("/meals")
    public PlannedMealResponse createMeal(Authentication authentication,
                                          @PathVariable Long groupId,
                                          @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateInWeek,
                                          @Valid @RequestBody CreatePlannedMealRequest request) {
        return mealPlanService.createMeal(authentication.getName(), groupId, dateInWeek, request);
    }

    /**
     * Updates an existing meal inside the selected weekly plan.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @param dateInWeek any date inside the requested week
     * @param mealId planned meal identifier
     * @param request updated meal data
     * @return updated planned meal
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
     * Deletes a meal from the selected weekly plan.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @param dateInWeek any date inside the requested week
     * @param mealId planned meal identifier
     */
    @DeleteMapping("/meals/{mealId}")
    public void deleteMeal(Authentication authentication,
                           @PathVariable Long groupId,
                           @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateInWeek,
                           @PathVariable Long mealId) {
        mealPlanService.deleteMeal(authentication.getName(), groupId, dateInWeek, mealId);
    }
}
