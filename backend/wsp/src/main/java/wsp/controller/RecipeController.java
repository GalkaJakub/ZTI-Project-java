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
 * Kontroler REST obsługujący przepisy zapisane w wybranej grupie.
 */
@RestController
@RequestMapping("/api/groups/{groupId}/recipes")
public class RecipeController {

    private final RecipeService recipeService;

    /**
     * Tworzy kontroler przepisów.
     *
     * @param recipeService serwis obsługujący przepisy grupowe
     */
    public RecipeController(RecipeService recipeService) {
        this.recipeService = recipeService;
    }

    /**
     * Zwraca wszystkie przepisy przypisane do grupy dostępnej dla użytkownika.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @return lista przepisów wraz ze składnikami
     */
    @GetMapping
    public List<RecipeResponse> getAll(Authentication authentication, @PathVariable Long groupId) {
        return recipeService.getAll(authentication.getName(), groupId);
    }

    /**
     * Zwraca pojedynczy przepis z wybranej grupy.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param recipeId identyfikator przepisu
     * @return szczegóły przepisu
     */
    @GetMapping("/{recipeId}")
    public RecipeResponse getById(Authentication authentication, @PathVariable Long groupId, @PathVariable Long recipeId) {
        return recipeService.getById(authentication.getName(), groupId, recipeId);
    }

    /**
     * Tworzy przepis z opcjonalną listą składników w wybranej grupie.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param request dane tworzonego przepisu
     * @return utworzony przepis
     */
    @PostMapping
    public RecipeResponse create(Authentication authentication,
                                 @PathVariable Long groupId,
                                 @Valid @RequestBody CreateRecipeRequest request) {
        return recipeService.create(authentication.getName(), groupId, request);
    }

    /**
     * Aktualizuje dane przepisu i zastępuje jego składniki.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param recipeId identyfikator przepisu
     * @param request nowe dane przepisu
     * @return zaktualizowany przepis
     */
    @PutMapping("/{recipeId}")
    public RecipeResponse update(Authentication authentication,
                                 @PathVariable Long groupId,
                                 @PathVariable Long recipeId,
                                 @Valid @RequestBody CreateRecipeRequest request) {
        return recipeService.update(authentication.getName(), groupId, recipeId, request);
    }

    /**
     * Usuwa przepis z wybranej grupy.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param recipeId identyfikator przepisu
     */
    @DeleteMapping("/{recipeId}")
    public void delete(Authentication authentication, @PathVariable Long groupId, @PathVariable Long recipeId) {
        recipeService.delete(authentication.getName(), groupId, recipeId);
    }
}
