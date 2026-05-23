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

@RestController
@RequestMapping("/api/groups/{groupId}/meal-plans/{dateInWeek}")
public class MealPlanController {

    private final MealPlanService mealPlanService;

    public MealPlanController(MealPlanService mealPlanService) {
        this.mealPlanService = mealPlanService;
    }

    @GetMapping
    public MealPlanResponse getWeekPlan(Authentication authentication,
                                        @PathVariable Long groupId,
                                        @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateInWeek) {
        return mealPlanService.getWeekPlan(authentication.getName(), groupId, dateInWeek);
    }

    @PostMapping("/meals")
    public PlannedMealResponse createMeal(Authentication authentication,
                                          @PathVariable Long groupId,
                                          @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateInWeek,
                                          @Valid @RequestBody CreatePlannedMealRequest request) {
        return mealPlanService.createMeal(authentication.getName(), groupId, dateInWeek, request);
    }

    @PutMapping("/meals/{mealId}")
    public PlannedMealResponse updateMeal(Authentication authentication,
                                          @PathVariable Long groupId,
                                          @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateInWeek,
                                          @PathVariable Long mealId,
                                          @Valid @RequestBody CreatePlannedMealRequest request) {
        return mealPlanService.updateMeal(authentication.getName(), groupId, dateInWeek, mealId, request);
    }

    @DeleteMapping("/meals/{mealId}")
    public void deleteMeal(Authentication authentication,
                           @PathVariable Long groupId,
                           @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateInWeek,
                           @PathVariable Long mealId) {
        mealPlanService.deleteMeal(authentication.getName(), groupId, dateInWeek, mealId);
    }
}
