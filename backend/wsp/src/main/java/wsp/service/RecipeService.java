package wsp.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import wsp.dto.CreateRecipeIngredientRequest;
import wsp.dto.CreateRecipeRequest;
import wsp.dto.RecipeResponse;
import wsp.entity.AppUser;
import wsp.entity.GroupMember;
import wsp.entity.Recipe;
import wsp.entity.RecipeIngredient;
import wsp.entity.UserGroup;
import wsp.repository.GroupMemberRepository;
import wsp.repository.RecipeRepository;
import wsp.repository.UserGroupRepository;
import wsp.repository.UserRepository;

import java.util.List;

@Service
public class RecipeService {

    private final RecipeRepository recipeRepository;
    private final UserGroupRepository userGroupRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final UserRepository userRepository;

    public RecipeService(RecipeRepository recipeRepository,
                         UserGroupRepository userGroupRepository,
                         GroupMemberRepository groupMemberRepository,
                         UserRepository userRepository) {
        this.recipeRepository = recipeRepository;
        this.userGroupRepository = userGroupRepository;
        this.groupMemberRepository = groupMemberRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<RecipeResponse> getAll(String email, Long groupId) {
        UserGroup group = getAccessibleGroup(email, groupId);
        return recipeRepository.findByGroupOrderByTitleAsc(group).stream()
                .map(RecipeResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public RecipeResponse getById(String email, Long groupId, Long recipeId) {
        UserGroup group = getAccessibleGroup(email, groupId);
        Recipe recipe = findById(group, recipeId);
        return RecipeResponse.fromEntity(recipe);
    }

    @Transactional
    public RecipeResponse create(String email, Long groupId, CreateRecipeRequest request) {
        UserGroup group = getAccessibleGroup(email, groupId);

        Recipe recipe = new Recipe();
        recipe.setGroup(group);
        updateRecipe(recipe, request);
        return RecipeResponse.fromEntity(recipeRepository.save(recipe));
    }

    @Transactional
    public RecipeResponse update(String email, Long groupId, Long recipeId, CreateRecipeRequest request) {
        UserGroup group = getAccessibleGroup(email, groupId);
        Recipe recipe = findById(group, recipeId);
        updateRecipe(recipe, request);
        return RecipeResponse.fromEntity(recipeRepository.save(recipe));
    }

    @Transactional
    public void delete(String email, Long groupId, Long recipeId) {
        UserGroup group = getAccessibleGroup(email, groupId);
        recipeRepository.delete(findById(group, recipeId));
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
