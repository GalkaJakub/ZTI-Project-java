package wsp.dto;

import wsp.entity.ShoppingItem;

public record ShoppingItemResponse(
        Long id,
        Long groupId,
        String name,
        String quantity,
        boolean bought
) {

    public static ShoppingItemResponse fromEntity(ShoppingItem item) {
        return new ShoppingItemResponse(
                item.getId(),
                item.getGroup().getId(),
                item.getName(),
                item.getQuantity(),
                item.isBought()
        );
    }
}
