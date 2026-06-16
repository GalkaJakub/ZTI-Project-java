package wsp.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.ShoppingItem;
import wsp.entity.UserGroup;

import java.util.List;
import java.util.Optional;

/**
 * Repozytorium produktów na grupowych listach zakupów.
 */
public interface ShoppingItemRepository extends JpaRepository<ShoppingItem, Long> {

    /**
     * Pobiera produkty grupy, najpierw niekupione, następnie według nazwy.
     *
     * @param group grupa właścicielska listy zakupów
     * @return lista produktów zakupowych
     */
    List<ShoppingItem> findByGroupOrderByBoughtAscNameAsc(UserGroup group);

    /**
     * Wyszukuje produkt po identyfikatorze tylko w obrębie wskazanej grupy.
     *
     * @param id identyfikator produktu
     * @param group grupa właścicielska produktu
     * @return produkt, jeśli należy do grupy
     */
    Optional<ShoppingItem> findByIdAndGroup(Long id, UserGroup group);
}
