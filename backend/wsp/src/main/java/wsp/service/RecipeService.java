package wsp.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import wsp.aop.Auditable;
import wsp.dto.CreateRecipeIngredientRequest;
import wsp.dto.CreateRecipeRequest;
import wsp.dto.RecipeResponse;
import wsp.entity.AuditAction;
import wsp.entity.AppUser;
import wsp.entity.GroupMember;
import wsp.entity.Recipe;
import wsp.entity.RecipeIngredient;
import wsp.entity.UserGroup;
import wsp.repository.GroupMemberRepository;
import wsp.repository.PlannedMealRepository;
import wsp.repository.RecipeRepository;
import wsp.repository.UserGroupRepository;
import wsp.repository.UserRepository;

import java.util.List;

/**
 * Serwis obsługujący przepisy i ich składniki w kontekście grupy.
 */
@Service
public class RecipeService {

    private final RecipeRepository recipeRepository;
    private final PlannedMealRepository plannedMealRepository;
    private final UserGroupRepository userGroupRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final UserRepository userRepository;

    /**
     * Tworzy serwis przepisów z repozytoriami potrzebnymi do obsługi grup i powiązań z planem posiłków.
     *
     * @param recipeRepository repozytorium przepisów
     * @param plannedMealRepository repozytorium posiłków powiązanych z przepisami
     * @param userGroupRepository repozytorium grup
     * @param groupMemberRepository repozytorium członkostw grupowych
     * @param userRepository repozytorium użytkowników
     */
    public RecipeService(RecipeRepository recipeRepository,
                         PlannedMealRepository plannedMealRepository,
                         UserGroupRepository userGroupRepository,
                         GroupMemberRepository groupMemberRepository,
                         UserRepository userRepository) {
        this.recipeRepository = recipeRepository;
        this.plannedMealRepository = plannedMealRepository;
        this.userGroupRepository = userGroupRepository;
        this.groupMemberRepository = groupMemberRepository;
        this.userRepository = userRepository;
    }

    /**
     * Pobiera przepisy dostępne dla użytkownika w danej grupie.
     *
     * @param email adres e-mail użytkownika
     * @param groupId identyfikator grupy
     * @return lista przepisów
     */
    @Transactional(readOnly = true)
    public List<RecipeResponse> getAll(String email, Long groupId) {
        UserGroup group = getAccessibleGroup(email, groupId);
        return recipeRepository.findByGroupOrderByTitleAsc(group).stream()
                .map(RecipeResponse::fromEntity)
                .toList();
    }

    /**
     * Pobiera szczegóły jednego przepisu po sprawdzeniu dostępu do grupy.
     *
     * @param email adres e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param recipeId identyfikator przepisu
     * @return szczegóły przepisu
     */
    @Transactional(readOnly = true)
    public RecipeResponse getById(String email, Long groupId, Long recipeId) {
        UserGroup group = getAccessibleGroup(email, groupId);
        Recipe recipe = findById(group, recipeId);
        return RecipeResponse.fromEntity(recipe);
    }

    /**
     * Tworzy przepis wraz ze składnikami i zapisuje zdarzenie audytu.
     *
     * @param email adres e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param request dane przepisu
     * @return utworzony przepis
     */
    @Transactional
    @Auditable(action = AuditAction.CREATE, entityType = "Recipe")
    public RecipeResponse create(String email, Long groupId, CreateRecipeRequest request) {
        UserGroup group = getAccessibleGroup(email, groupId);

        Recipe recipe = new Recipe();
        recipe.setGroup(group);
        updateRecipe(recipe, request);
        return RecipeResponse.fromEntity(recipeRepository.save(recipe));
    }

    /**
     * Aktualizuje przepis, zastępuje składniki i zapisuje zdarzenie audytu.
     *
     * @param email adres e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param recipeId identyfikator przepisu
     * @param request nowe dane przepisu
     * @return zaktualizowany przepis
     */
    @Transactional
    @Auditable(action = AuditAction.UPDATE, entityType = "Recipe", entityIdArg = "recipeId")
    public RecipeResponse update(String email, Long groupId, Long recipeId, CreateRecipeRequest request) {
        UserGroup group = getAccessibleGroup(email, groupId);
        Recipe recipe = findById(group, recipeId);
        updateRecipe(recipe, request);
        return RecipeResponse.fromEntity(recipeRepository.save(recipe));
    }

    /**
     * Usuwa przepis, odpina go od zaplanowanych posiłków i zapisuje zdarzenie audytu.
     *
     * @param email adres e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param recipeId identyfikator przepisu
     */
    @Transactional
    @Auditable(action = AuditAction.DELETE, entityType = "Recipe", entityIdArg = "recipeId")
    public void delete(String email, Long groupId, Long recipeId) {
        UserGroup group = getAccessibleGroup(email, groupId);
        Recipe recipe = findById(group, recipeId);
        plannedMealRepository.findByRecipe(recipe)
                .forEach(meal -> meal.setRecipe(null));
        recipeRepository.delete(recipe);
    }

    private Recipe findById(UserGroup group, Long recipeId) {
        return recipeRepository.findByIdAndGroup(recipeId, group)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found"));
    }

    private void updateRecipe(Recipe recipe, CreateRecipeRequest request) {
        recipe.setTitle(request.title().trim());
        recipe.setDescription(request.description() == null ? null : request.description().trim());
        recipe.setInstructions(request.instructions().trim());

        recipe.clearIngredients();
        if (request.ingredients() == null) {
            return;
        }

        request.ingredients().stream()
                .map(this::toIngredient)
                .forEach(recipe::addIngredient);
    }

    private RecipeIngredient toIngredient(CreateRecipeIngredientRequest request) {
        RecipeIngredient ingredient = new RecipeIngredient();
        ingredient.setName(request.name());
        ingredient.setQuantity(request.quantity());
        return ingredient;
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
