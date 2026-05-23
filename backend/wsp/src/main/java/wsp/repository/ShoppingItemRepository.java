package wsp.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.ShoppingItem;
import wsp.entity.UserGroup;

import java.util.List;
import java.util.Optional;

public interface ShoppingItemRepository extends JpaRepository<ShoppingItem, Long> {

    List<ShoppingItem> findByGroupOrderByBoughtAscNameAsc(UserGroup group);

    Optional<ShoppingItem> findByIdAndGroup(Long id, UserGroup group);
}
