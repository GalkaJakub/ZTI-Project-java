package wsp.controller;

import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import wsp.dto.CreateRecipeRequest;
import wsp.dto.RecipeResponse;
import wsp.service.RecipeService;

import java.util.List;

/**
 * REST controller for recipes stored inside a selected group.
 */
@RestController
@RequestMapping("/api/groups/{groupId}/recipes")
public class RecipeController {

    private final RecipeService recipeService;

    public RecipeController(RecipeService recipeService) {
        this.recipeService = recipeService;
    }

    /**
     * Returns all recipes assigned to a group visible to the current user.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @return list of recipes with ingredients
     */
    @GetMapping
    public List<RecipeResponse> getAll(Authentication authentication, @PathVariable Long groupId) {
        return recipeService.getAll(authentication.getName(), groupId);
    }

    /**
     * Returns one recipe from a group.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @param recipeId recipe identifier
     * @return recipe details
     */
    @GetMapping("/{recipeId}")
    public RecipeResponse getById(Authentication authentication, @PathVariable Long groupId, @PathVariable Long recipeId) {
        return recipeService.getById(authentication.getName(), groupId, recipeId);
    }

    /**
     * Creates a recipe with optional ingredients in the selected group.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @param request recipe creation data
     * @return created recipe
     */
    @PostMapping
    public RecipeResponse create(Authentication authentication,
                                 @PathVariable Long groupId,
                                 @Valid @RequestBody CreateRecipeRequest request) {
        return recipeService.create(authentication.getName(), groupId, request);
    }

    /**
     * Updates recipe data and replaces its ingredients.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @param recipeId recipe identifier
     * @param request new recipe data
     * @return updated recipe
     */
    @PutMapping("/{recipeId}")
    public RecipeResponse update(Authentication authentication,
                                 @PathVariable Long groupId,
                                 @PathVariable Long recipeId,
                                 @Valid @RequestBody CreateRecipeRequest request) {
        return recipeService.update(authentication.getName(), groupId, recipeId, request);
    }

    /**
     * Deletes a recipe from the selected group.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @param recipeId recipe identifier
     */
    @DeleteMapping("/{recipeId}")
    public void delete(Authentication authentication, @PathVariable Long groupId, @PathVariable Long recipeId) {
        recipeService.delete(authentication.getName(), groupId, recipeId);
    }
}
