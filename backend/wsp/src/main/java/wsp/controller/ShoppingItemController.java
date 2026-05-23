package wsp.controller;

import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import wsp.dto.CreateShoppingItemRequest;
import wsp.dto.ShoppingItemResponse;
import wsp.service.ShoppingItemService;

import java.util.List;

@RestController
@RequestMapping("/api/groups/{groupId}/shopping-items")
public class ShoppingItemController {

    private final ShoppingItemService shoppingItemService;

    public ShoppingItemController(ShoppingItemService shoppingItemService) {
        this.shoppingItemService = shoppingItemService;
    }

    @GetMapping
    public List<ShoppingItemResponse> getAll(Authentication authentication, @PathVariable Long groupId) {
        return shoppingItemService.getAll(authentication.getName(), groupId);
    }

    @PostMapping
    public ShoppingItemResponse create(Authentication authentication, @PathVariable Long groupId, @Valid @RequestBody CreateShoppingItemRequest request) {
        return shoppingItemService.create(authentication.getName(), groupId, request);
    }

    @PatchMapping("/{itemId}/toggle")
    public ShoppingItemResponse toggle(Authentication authentication, @PathVariable Long groupId, @PathVariable Long itemId) {
        return shoppingItemService.toggleBought(authentication.getName(), groupId, itemId);
    }

    @DeleteMapping("/{itemId}")
    public void delete(Authentication authentication, @PathVariable Long groupId, @PathVariable Long itemId) {
        shoppingItemService.delete(authentication.getName(), groupId, itemId);
    }
}
