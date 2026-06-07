package wsp;

import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import wsp.entity.AppUser;
import wsp.entity.GroupMember;
import wsp.entity.GroupRole;
import wsp.entity.UserGroup;
import wsp.repository.AuditLogRepository;
import wsp.repository.GroupMemberRepository;
import wsp.repository.MealPlanRepository;
import wsp.repository.PlannedMealRepository;
import wsp.repository.RecipeRepository;
import wsp.repository.ShoppingItemRepository;
import wsp.repository.UserGroupRepository;
import wsp.repository.UserRepository;

import java.util.UUID;

@SpringBootTest
public abstract class ServiceIntegrationTestSupport {

    @Autowired
    protected AuditLogRepository auditLogRepository;

    @Autowired
    protected PlannedMealRepository plannedMealRepository;

    @Autowired
    protected MealPlanRepository mealPlanRepository;

    @Autowired
    protected RecipeRepository recipeRepository;

    @Autowired
    protected ShoppingItemRepository shoppingItemRepository;

    @Autowired
    protected GroupMemberRepository groupMemberRepository;

    @Autowired
    protected UserGroupRepository userGroupRepository;

    @Autowired
    protected UserRepository userRepository;

    @BeforeEach
    void cleanDatabase() {
        auditLogRepository.deleteAll();
        plannedMealRepository.deleteAll();
        mealPlanRepository.deleteAll();
        recipeRepository.deleteAll();
        shoppingItemRepository.deleteAll();
        groupMemberRepository.deleteAll();
        userGroupRepository.deleteAll();
        userRepository.deleteAll();
    }

    protected AppUser createUser(String prefix) {
        String unique = UUID.randomUUID().toString();

        AppUser user = new AppUser();
        user.setEmail(prefix + "-" + unique + "@example.com");
        user.setDisplayName(prefix + " user");
        user.setPasswordHash("hash");
        return userRepository.save(user);
    }

    protected TestMembership createMembership(String prefix) {
        AppUser user = createUser(prefix);

        UserGroup group = new UserGroup();
        group.setName(prefix + " group");
        group.setInviteCode(UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        UserGroup savedGroup = userGroupRepository.save(group);

        GroupMember member = new GroupMember();
        member.setUser(user);
        member.setGroup(savedGroup);
        member.setRole(GroupRole.OWNER);
        groupMemberRepository.save(member);

        return new TestMembership(user, savedGroup);
    }

    protected record TestMembership(AppUser user, UserGroup group) {
    }
}
