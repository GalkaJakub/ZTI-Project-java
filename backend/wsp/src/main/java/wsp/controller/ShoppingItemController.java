package wsp.controller;

import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import wsp.dto.CreateShoppingItemRequest;
import wsp.dto.ShoppingItemResponse;
import wsp.service.ShoppingItemService;

import java.util.List;

/**
 * REST controller for group-scoped shopping list operations.
 */
@RestController
@RequestMapping("/api/groups/{groupId}/shopping-items")
public class ShoppingItemController {

    private final ShoppingItemService shoppingItemService;

    public ShoppingItemController(ShoppingItemService shoppingItemService) {
        this.shoppingItemService = shoppingItemService;
    }

    /**
     * Returns all shopping items for a group visible to the current user.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @return shopping items ordered by bought flag and name
     */
    @GetMapping
    public List<ShoppingItemResponse> getAll(Authentication authentication, @PathVariable Long groupId) {
        return shoppingItemService.getAll(authentication.getName(), groupId);
    }

    /**
     * Adds a new shopping item to the selected group.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @param request item creation data
     * @return created item
     */
    @PostMapping
    public ShoppingItemResponse create(Authentication authentication, @PathVariable Long groupId, @Valid @RequestBody CreateShoppingItemRequest request) {
        return shoppingItemService.create(authentication.getName(), groupId, request);
    }

    /**
     * Toggles the bought status of a shopping item.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @param itemId shopping item identifier
     * @return updated item
     */
    @PatchMapping("/{itemId}/toggle")
    public ShoppingItemResponse toggle(Authentication authentication, @PathVariable Long groupId, @PathVariable Long itemId) {
        return shoppingItemService.toggleBought(authentication.getName(), groupId, itemId);
    }

    /**
     * Deletes a shopping item from the selected group.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @param itemId shopping item identifier
     */
    @DeleteMapping("/{itemId}")
    public void delete(Authentication authentication, @PathVariable Long groupId, @PathVariable Long itemId) {
        shoppingItemService.delete(authentication.getName(), groupId, itemId);
    }
}
