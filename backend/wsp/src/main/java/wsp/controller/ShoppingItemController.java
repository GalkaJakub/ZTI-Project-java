package wsp.controller;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;
import wsp.dto.CreateShoppingItemRequest;
import wsp.entity.ShoppingItem;
import wsp.service.ShoppingItemService;

import java.util.List;

@RestController
@RequestMapping("/api/shopping-items")
public class ShoppingItemController {

    private final ShoppingItemService shoppingItemService;

    public ShoppingItemController(ShoppingItemService shoppingItemService) {
        this.shoppingItemService = shoppingItemService;
    }

    @GetMapping
    public List<ShoppingItem> getAll() {
        return shoppingItemService.getAll();
    }

    @PostMapping
    public ShoppingItem create(@Valid @RequestBody CreateShoppingItemRequest request) {
        return shoppingItemService.create(request.name());
    }

    @PatchMapping("/{id}/toggle")
    public ShoppingItem toggle(@PathVariable Long id) {
        return shoppingItemService.toggleBought(id);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        shoppingItemService.delete(id);
    }
}
