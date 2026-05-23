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

@RestController
@RequestMapping("/api/groups/{groupId}/recipes")
public class RecipeController {

    private final RecipeService recipeService;

    public RecipeController(RecipeService recipeService) {
        this.recipeService = recipeService;
    }

    @GetMapping
    public List<RecipeResponse> getAll(Authentication authentication, @PathVariable Long groupId) {
        return recipeService.getAll(authentication.getName(), groupId);
    }

    @GetMapping("/{recipeId}")
    public RecipeResponse getById(Authentication authentication, @PathVariable Long groupId, @PathVariable Long recipeId) {
        return recipeService.getById(authentication.getName(), groupId, recipeId);
    }

    @PostMapping
    public RecipeResponse create(Authentication authentication,
                                 @PathVariable Long groupId,
                                 @Valid @RequestBody CreateRecipeRequest request) {
        return recipeService.create(authentication.getName(), groupId, request);
    }

    @PutMapping("/{recipeId}")
    public RecipeResponse update(Authentication authentication,
                                 @PathVariable Long groupId,
                                 @PathVariable Long recipeId,
                                 @Valid @RequestBody CreateRecipeRequest request) {
        return recipeService.update(authentication.getName(), groupId, recipeId, request);
    }

    @DeleteMapping("/{recipeId}")
    public void delete(Authentication authentication, @PathVariable Long groupId, @PathVariable Long recipeId) {
        recipeService.delete(authentication.getName(), groupId, recipeId);
    }
}
