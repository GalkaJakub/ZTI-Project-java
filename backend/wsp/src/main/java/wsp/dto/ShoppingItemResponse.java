package wsp.dto;

import wsp.entity.ShoppingItem;

/**
 * Odpowiedź opisująca produkt na liście zakupów.
 *
 * @param id identyfikator produktu
 * @param groupId identyfikator grupy, do której należy produkt
 * @param name nazwa produktu
 * @param quantity ilość produktu
 * @param bought informacja, czy produkt został oznaczony jako kupiony
 */
public record ShoppingItemResponse(
        Long id,
        Long groupId,
        String name,
        String quantity,
        boolean bought
) {

    /**
     * Tworzy DTO produktu z encji JPA.
     *
     * @param item encja produktu zakupowego
     * @return odpowiedź z produktem
     */
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
