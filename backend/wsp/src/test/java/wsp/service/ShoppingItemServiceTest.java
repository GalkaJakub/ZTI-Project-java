package wsp.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import wsp.ServiceIntegrationTestSupport;
import wsp.dto.CreateShoppingItemRequest;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ShoppingItemServiceTest extends ServiceIntegrationTestSupport {

    @Autowired
    private ShoppingItemService shoppingItemService;

    @Test
    void createsTogglesAndDeletesShoppingItem() {
        TestMembership membership = createMembership("shopping");

        var createdItem = shoppingItemService.create(
                membership.user().getEmail(),
                membership.group().getId(),
                new CreateShoppingItemRequest("  Mleko  ", "  1 l  ")
        );

        assertThat(createdItem.id()).isNotNull();
        assertThat(createdItem.name()).isEqualTo("Mleko");
        assertThat(createdItem.quantity()).isEqualTo("1 l");
        assertThat(createdItem.bought()).isFalse();

        var toggledItem = shoppingItemService.toggleBought(
                membership.user().getEmail(),
                membership.group().getId(),
                createdItem.id()
        );

        assertThat(toggledItem.bought()).isTrue();

        shoppingItemService.delete(membership.user().getEmail(), membership.group().getId(), createdItem.id());

        assertThat(shoppingItemRepository.existsById(createdItem.id())).isFalse();
        assertThat(shoppingItemService.getAll(membership.user().getEmail(), membership.group().getId())).isEmpty();
    }

    @Test
    void rejectsAccessToGroupForNonMember() {
        TestMembership ownerMembership = createMembership("owner");
        var outsider = createUser("outsider");

        assertThatThrownBy(() -> shoppingItemService.create(outsider.getEmail(), ownerMembership.group().getId(),
                new CreateShoppingItemRequest("Chleb", "1 szt.")
        )).isInstanceOfSatisfying(ResponseStatusException.class, exception ->
                assertThat(exception.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN));
    }
}
