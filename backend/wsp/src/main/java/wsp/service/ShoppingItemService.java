package wsp.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import wsp.aop.Auditable;
import wsp.dto.CreateShoppingItemRequest;
import wsp.dto.ShoppingItemResponse;
import wsp.entity.AuditAction;
import wsp.entity.AppUser;
import wsp.entity.GroupMember;
import wsp.entity.ShoppingItem;
import wsp.entity.UserGroup;
import wsp.repository.GroupMemberRepository;
import wsp.repository.ShoppingItemRepository;
import wsp.repository.UserGroupRepository;
import wsp.repository.UserRepository;

import java.util.List;

/**
 * Serwis obsługujący listę zakupów w ramach grup użytkowników.
 */
@Service
public class ShoppingItemService {

    private final ShoppingItemRepository shoppingItemRepository;
    private final UserGroupRepository userGroupRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final UserRepository userRepository;

    /**
     * Tworzy serwis listy zakupów z repozytoriami do zapisu produktów i kontroli członkostwa.
     *
     * @param shoppingItemRepository repozytorium produktów zakupowych
     * @param userGroupRepository repozytorium grup
     * @param groupMemberRepository repozytorium członkostw grupowych
     * @param userRepository repozytorium użytkowników
     */
    public ShoppingItemService(ShoppingItemRepository shoppingItemRepository,
                               UserGroupRepository userGroupRepository,
                               GroupMemberRepository groupMemberRepository,
                               UserRepository userRepository) {
        this.shoppingItemRepository = shoppingItemRepository;
        this.userGroupRepository = userGroupRepository;
        this.groupMemberRepository = groupMemberRepository;
        this.userRepository = userRepository;
    }

    /**
     * Pobiera produkty z listy zakupów po sprawdzeniu dostępu użytkownika do grupy.
     *
     * @param email adres e-mail użytkownika
     * @param groupId identyfikator grupy
     * @return lista produktów zakupowych
     */
    @Transactional(readOnly = true)
    public List<ShoppingItemResponse> getAll(String email, Long groupId) {
        UserGroup group = getAccessibleGroup(email, groupId);
        return shoppingItemRepository.findByGroupOrderByBoughtAscNameAsc(group).stream()
                .map(ShoppingItemResponse::fromEntity)
                .toList();
    }

    /**
     * Tworzy produkt na liście zakupów grupy i zapisuje zdarzenie audytu.
     *
     * @param email adres e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param request dane produktu
     * @return utworzony produkt
     */
    @Transactional
    @Auditable(action = AuditAction.CREATE, entityType = "ShoppingItem")
    public ShoppingItemResponse create(String email, Long groupId, CreateShoppingItemRequest request) {
        UserGroup group = getAccessibleGroup(email, groupId);

        ShoppingItem item = new ShoppingItem();
        item.setName(request.name().trim());
        item.setQuantity(request.quantity().trim());
        item.setBought(false);
        item.setGroup(group);

        return ShoppingItemResponse.fromEntity(shoppingItemRepository.save(item));
    }

    /**
     * Przełącza status kupienia produktu i zapisuje zdarzenie audytu.
     *
     * @param email adres e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param itemId identyfikator produktu
     * @return zaktualizowany produkt
     */
    @Transactional
    @Auditable(action = AuditAction.MARK_AS_PURCHASED, entityType = "ShoppingItem", entityIdArg = "itemId")
    public ShoppingItemResponse toggleBought(String email, Long groupId, Long itemId) {
        UserGroup group = getAccessibleGroup(email, groupId);
        ShoppingItem item = findItem(group, itemId);
        item.setBought(!item.isBought());
        return ShoppingItemResponse.fromEntity(shoppingItemRepository.save(item));
    }

    /**
     * Usuwa produkt z listy zakupów i zapisuje zdarzenie audytu.
     *
     * @param email adres e-mail użytkownika
     * @param groupId identyfikator grupy
     * @param itemId identyfikator produktu
     */
    @Transactional
    @Auditable(action = AuditAction.DELETE, entityType = "ShoppingItem", entityIdArg = "itemId")
    public void delete(String email, Long groupId, Long itemId) {
        UserGroup group = getAccessibleGroup(email, groupId);
        shoppingItemRepository.delete(findItem(group, itemId));
    }

    private UserGroup getAccessibleGroup(String email, Long groupId) {
        AppUser user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        UserGroup group = userGroupRepository.findById(groupId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Group not found"));
        requireMembership(group, user);
        return group;
    }

    private GroupMember requireMembership(UserGroup group, AppUser user) {
        return groupMemberRepository.findByGroupAndUser(group, user)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "User does not belong to this group"));
    }

    private ShoppingItem findItem(UserGroup group, Long itemId) {
        return shoppingItemRepository.findByIdAndGroup(itemId, group)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping item not found"));
    }
}
