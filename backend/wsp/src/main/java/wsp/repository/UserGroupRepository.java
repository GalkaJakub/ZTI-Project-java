package wsp.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.UserGroup;

import java.util.Optional;

public interface UserGroupRepository extends JpaRepository<UserGroup, Long> {

    Optional<UserGroup> findByInviteCodeIgnoreCase(String inviteCode);

    boolean existsByInviteCode(String inviteCode);
}
