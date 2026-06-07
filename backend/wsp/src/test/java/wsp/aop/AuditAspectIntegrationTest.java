package wsp.aop;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import wsp.ServiceIntegrationTestSupport;
import wsp.dto.CreateShoppingItemRequest;
import wsp.entity.AuditAction;
import wsp.service.ShoppingItemService;

import static org.assertj.core.api.Assertions.assertThat;

class AuditAspectIntegrationTest extends ServiceIntegrationTestSupport {

    @Autowired
    private ShoppingItemService shoppingItemService;

    @Test
    void writesAuditLogsForAuditedShoppingOperations() {
        TestMembership membership = createMembership("audit");

        var createdItem = shoppingItemService.create(
                membership.user().getEmail(),
                membership.group().getId(),
                new CreateShoppingItemRequest("Mleko", "1 l")
        );
        shoppingItemService.toggleBought(membership.user().getEmail(), membership.group().getId(), createdItem.id());
        shoppingItemService.delete(membership.user().getEmail(), membership.group().getId(), createdItem.id());

        assertThat(auditLogRepository.findAll()).hasSize(3).allSatisfy(log -> {
                    assertThat(log.getEntityType()).isEqualTo("ShoppingItem");
                    assertThat(log.getGroupId()).isEqualTo(membership.group().getId());
                    assertThat(log.getActorEmail()).isEqualTo(membership.user().getEmail());
                    assertThat(log.getEntityId()).isEqualTo(createdItem.id());
                    assertThat(log.getCreatedAt()).isNotNull();
                })
                .extracting("action")
                .containsExactly(AuditAction.CREATE, AuditAction.MARK_AS_PURCHASED, AuditAction.DELETE);
    }
}
