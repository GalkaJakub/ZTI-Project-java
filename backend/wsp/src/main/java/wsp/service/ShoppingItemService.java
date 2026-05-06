package wsp.service;

import org.springframework.stereotype.Service;
import wsp.entity.ShoppingItem;
import wsp.repository.ShoppingItemRepository;

import java.util.List;

@Service
public class ShoppingItemService {

    private final ShoppingItemRepository shoppingItemRepository;

    public ShoppingItemService(ShoppingItemRepository shoppingItemRepository) {
        this.shoppingItemRepository = shoppingItemRepository;
    }

    public List<ShoppingItem> getAll() {
        return shoppingItemRepository.findAll();
    }

    public ShoppingItem create(String name) {
        ShoppingItem item = new ShoppingItem();
        item.setName(name);
        item.setBought(false);
        return shoppingItemRepository.save(item);
    }

    public ShoppingItem toggleBought(Long id) {
        ShoppingItem item = shoppingItemRepository.findById(id).orElseThrow(() -> new RuntimeException("Item not found"));
        item.setBought(!item.isBought());
        return shoppingItemRepository.save(item);
    }

    public void delete(Long id) {
        if (!shoppingItemRepository.existsById(id)) {
            throw new RuntimeException("Shopping item not found");
        }
        shoppingItemRepository.deleteById(id);
    }
}
