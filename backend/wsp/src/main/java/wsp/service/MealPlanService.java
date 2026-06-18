package wsp.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import wsp.aop.Auditable;
import wsp.dto.CreatePlannedMealRequest;
import wsp.dto.MealPlanResponse;
import wsp.dto.PlannedMealResponse;
import wsp.entity.AuditAction;
import wsp.entity.AppUser;
import wsp.entity.GroupMember;
import wsp.entity.MealPlan;
import wsp.entity.PlannedMeal;
import wsp.entity.Recipe;
import wsp.entity.UserGroup;
import wsp.repository.GroupMemberRepository;
import wsp.repository.MealPlanRepository;
import wsp.repository.PlannedMealRepository;
import wsp.repository.RecipeRepository;
import wsp.repository.UserGroupRepository;
import wsp.repository.UserRepository;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;

/**
 * Serwis obsługujący tygodniowe plany posiłków oraz zaplanowane posiłki.
 */
@Service
public class MealPlanService {

    private final MealPlanRepository mealPlanRepository;
    private final PlannedMealRepository plannedMealRepository;
    private final RecipeRepository recipeRepository;
    private final UserGroupRepository userGroupRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final UserRepository userRepository;

    /**
     * Tworzy serwis planów posiłków z repozytoriami wymaganymi do walidacji dostępu i zapisu posiłków.
     *
     * @param mealPlanRepository repozytorium tygodniowych planów posiłków
     * @param plannedMealRepository repozytorium zaplanowanych posiłków
     * @param recipeRepository repozytorium przepisów
     * @param userGroupRepository repozytorium grup
     * @param groupMemberRepository repozytorium członkostw grupowych
     * @param userRepository repozytorium użytkowników
     */
    public MealPlanService(MealPlanRepository mealPlanRepository,
                           PlannedMealRepository plannedMealRepository,
                           RecipeRepository recipeRepository,
                           UserGroupRepository userGroupRepository,
                           GroupMemberRepository groupMemberRepository,
                           UserRepository userRepository) {
        this.mealPlanRepository = mealPlanRepository;
        this.plannedMealRepository = plannedMealRepository;
        this.recipeRepository = recipeRepository;
        this.userGroupRepository = userGroupRepository;
        this.groupMemberRepository = groupMemberRepository;
        this.userRepository = userRepository;
    }

    /**
     * Pobiera lub tworzy tygodniowy plan posiłków dla grupy.
     *
     * @param email adres e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param dateInWeek dowolna data z wybranego tygodnia
     * @return tygodniowy plan posiłków
     */
    @Transactional
    public MealPlanResponse getWeekPlan(String email, Long groupId, LocalDate dateInWeek) {
        UserGroup group = getAccessibleGroup(email, groupId);
        MealPlan mealPlan = getOrCreateMealPlan(group, startOfWeek(dateInWeek));
        return MealPlanResponse.fromEntity(mealPlan);
    }

    /**
     * Dodaje posiłek do tygodniowego planu i zapisuje zdarzenie audytu.
     *
     * @param email adres e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param dateInWeek dowolna data z wybranego tygodnia
     * @param request dane posiłku
     * @return utworzony zaplanowany posiłek
     */
    @Transactional
    @Auditable(action = AuditAction.CREATE, entityType = "PlannedMeal")
    public PlannedMealResponse createMeal(String email, Long groupId, LocalDate dateInWeek, CreatePlannedMealRequest request) {
        UserGroup group = getAccessibleGroup(email, groupId);
        LocalDate weekStartDate = startOfWeek(dateInWeek);
        validateMealDate(weekStartDate, request.mealDate());

        MealPlan mealPlan = getOrCreateMealPlan(group, weekStartDate);
        PlannedMeal meal = new PlannedMeal();
        updateMeal(meal, group, request);
        addMealToPlan(mealPlan, meal);

        PlannedMeal savedMeal = plannedMealRepository.saveAndFlush(meal);
        return PlannedMealResponse.fromEntity(savedMeal);
    }

    /**
     * Aktualizuje posiłek w tygodniowym planie i zapisuje zdarzenie audytu.
     *
     * @param email adres e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param dateInWeek dowolna data z wybranego tygodnia
     * @param mealId identyfikator zaplanowanego posiłku
     * @param request nowe dane posiłku
     * @return zaktualizowany zaplanowany posiłek
     */
    @Transactional
    @Auditable(action = AuditAction.UPDATE, entityType = "PlannedMeal", entityIdArg = "mealId")
    public PlannedMealResponse updateMeal(String email, Long groupId, LocalDate dateInWeek, Long mealId, CreatePlannedMealRequest request) {
        UserGroup group = getAccessibleGroup(email, groupId);
        LocalDate weekStartDate = startOfWeek(dateInWeek);
        validateMealDate(weekStartDate, request.mealDate());

        MealPlan mealPlan = findMealPlan(group, weekStartDate);
        PlannedMeal meal = findMeal(mealPlan, mealId);
        updateMeal(meal, group, request);

        return PlannedMealResponse.fromEntity(plannedMealRepository.save(meal));
    }

    /**
     * Usuwa posiłek z tygodniowego planu i zapisuje zdarzenie audytu.
     *
     * @param email adres e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param dateInWeek dowolna data z wybranego tygodnia
     * @param mealId identyfikator zaplanowanego posiłku
     */
    @Transactional
    @Auditable(action = AuditAction.DELETE, entityType = "PlannedMeal", entityIdArg = "mealId")
    public void deleteMeal(String email, Long groupId, LocalDate dateInWeek, Long mealId) {
        UserGroup group = getAccessibleGroup(email, groupId);
        MealPlan mealPlan = findMealPlan(group, startOfWeek(dateInWeek));
        PlannedMeal meal = findMeal(mealPlan, mealId);
        removeMealFromPlan(mealPlan, meal);
        mealPlanRepository.saveAndFlush(mealPlan);
    }

    private void addMealToPlan(MealPlan mealPlan, PlannedMeal meal) {
        mealPlan.getMeals().add(meal);
        meal.setMealPlan(mealPlan);
    }

    private void removeMealFromPlan(MealPlan mealPlan, PlannedMeal meal) {
        mealPlan.getMeals().remove(meal);
        meal.setMealPlan(null);
    }

    private MealPlan getOrCreateMealPlan(UserGroup group, LocalDate weekStartDate) {
        return mealPlanRepository.findByGroupAndWeekStartDate(group, weekStartDate)
                .orElseGet(() -> {
                    MealPlan mealPlan = new MealPlan();
                    mealPlan.setGroup(group);
                    mealPlan.setWeekStartDate(weekStartDate);
                    return mealPlanRepository.save(mealPlan);
                });
    }

    private MealPlan findMealPlan(UserGroup group, LocalDate weekStartDate) {
        return mealPlanRepository.findByGroupAndWeekStartDate(group, weekStartDate)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Meal plan not found"));
    }

    private PlannedMeal findMeal(MealPlan mealPlan, Long mealId) {
        return plannedMealRepository.findByIdAndMealPlan(mealId, mealPlan)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Planned meal not found"));
    }

    private void updateMeal(PlannedMeal meal, UserGroup group, CreatePlannedMealRequest request) {
        meal.setMealDate(request.mealDate());
        meal.setMealType(request.mealType());
        meal.setTitle(request.title().trim());
        meal.setNotes(request.notes() == null ? null : request.notes().trim());
        meal.setRecipe(findRecipe(group, request.recipeId()));
    }

    private Recipe findRecipe(UserGroup group, Long recipeId) {
        if (recipeId == null) {
            return null;
        }

        return recipeRepository.findByIdAndGroup(recipeId, group)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found"));
    }

    private void validateMealDate(LocalDate weekStartDate, LocalDate mealDate) {
        if (mealDate.isBefore(weekStartDate) || mealDate.isAfter(weekStartDate.plusDays(6))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Meal date must be within selected week");
        }
    }

    private LocalDate startOfWeek(LocalDate date) {
        return date.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
    }

    private UserGroup getAccessibleGroup(String email, Long groupId) {
        AppUser user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        UserGroup group = userGroupRepository.findById(groupId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Group not found"));
        requireMembership(group, user);
        return group;
    }

    private GroupMember requireMembership(UserGroup group, AppUser user) {
        return groupMemberRepository.findByGroupAndUser(group, user)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "User does not belong to this group"));
    }
}
