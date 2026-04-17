package wsp.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.ShoppingItem;

public interface ShoppingItemRepository extends JpaRepository<ShoppingItem, Long> {
}
