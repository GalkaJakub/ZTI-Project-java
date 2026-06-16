package wsp.controller;

import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import wsp.dto.CreateShoppingItemRequest;
import wsp.dto.ShoppingItemResponse;
import wsp.service.ShoppingItemService;

import java.util.List;

/**
 * Kontroler REST obsługujący listę zakupów w kontekście wybranej grupy.
 */
@RestController
@RequestMapping("/api/groups/{groupId}/shopping-items")
public class ShoppingItemController {

    private final ShoppingItemService shoppingItemService;

    /**
     * Tworzy kontroler listy zakupów.
     *
     * @param shoppingItemService serwis obsługujący produkty na liście zakupów
     */
    public ShoppingItemController(ShoppingItemService shoppingItemService) {
        this.shoppingItemService = shoppingItemService;
    }

    /**
     * Zwraca wszystkie produkty z listy zakupów grupy dostępnej dla użytkownika.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @return produkty posortowane według statusu zakupu i nazwy
     */
    @GetMapping
    public List<ShoppingItemResponse> getAll(Authentication authentication, @PathVariable Long groupId) {
        return shoppingItemService.getAll(authentication.getName(), groupId);
    }

    /**
     * Dodaje nowy produkt do listy zakupów wybranej grupy.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param request dane tworzonego produktu
     * @return utworzony produkt
     */
    @PostMapping
    public ShoppingItemResponse create(Authentication authentication, @PathVariable Long groupId, @Valid @RequestBody CreateShoppingItemRequest request) {
        return shoppingItemService.create(authentication.getName(), groupId, request);
    }

    /**
     * Przełącza status kupienia produktu.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param itemId identyfikator produktu
     * @return zaktualizowany produkt
     */
    @PatchMapping("/{itemId}/toggle")
    public ShoppingItemResponse toggle(Authentication authentication, @PathVariable Long groupId, @PathVariable Long itemId) {
        return shoppingItemService.toggleBought(authentication.getName(), groupId, itemId);
    }

    /**
     * Usuwa produkt z listy zakupów wybranej grupy.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param itemId identyfikator produktu
     */
    @DeleteMapping("/{itemId}")
    public void delete(Authentication authentication, @PathVariable Long groupId, @PathVariable Long itemId) {
        shoppingItemService.delete(authentication.getName(), groupId, itemId);
    }
}
