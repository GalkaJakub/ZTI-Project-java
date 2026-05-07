package wsp.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import wsp.dto.CreateRecipeIngredientRequest;
import wsp.dto.CreateRecipeRequest;
import wsp.dto.RecipeResponse;
import wsp.entity.Recipe;
import wsp.entity.RecipeIngredient;
import wsp.repository.RecipeRepository;

import java.util.List;

@Service
public class RecipeService {

    private final RecipeRepository recipeRepository;

    public RecipeService(RecipeRepository recipeRepository) {
        this.recipeRepository = recipeRepository;
    }

    public List<RecipeResponse> getAll() {
        return recipeRepository.findAllByOrderByTitleAsc().stream()
                .map(RecipeResponse::fromEntity)
                .toList();
    }

    public RecipeResponse getById(Long id) {
        Recipe recipe = findById(id);
        return RecipeResponse.fromEntity(recipe);
    }

    public RecipeResponse create(CreateRecipeRequest request) {
        Recipe recipe = new Recipe();
        updateRecipe(recipe, request);
        return RecipeResponse.fromEntity(recipeRepository.save(recipe));
    }

    public RecipeResponse update(Long id, CreateRecipeRequest request) {
        Recipe recipe = findById(id);
        updateRecipe(recipe, request);
        return RecipeResponse.fromEntity(recipeRepository.save(recipe));
    }

    public void delete(Long id) {
        if (!recipeRepository.existsById(id)) {
            throw new RuntimeException("Recipe not found");
        }
        recipeRepository.deleteById(id);
    }

    private Recipe findById(Long id) {
        return recipeRepository.findWithIngredientsById(id)
                .orElseThrow(() -> new RuntimeException("Recipe not found"));
    }

    private void updateRecipe(Recipe recipe, CreateRecipeRequest request) {
        recipe.setTitle(request.title());
        recipe.setDescription(request.description());
        recipe.setInstructions(request.instructions());

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
}
