package wsp.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.AppUser;
import wsp.entity.GroupMember;
import wsp.entity.UserGroup;

import java.util.List;
import java.util.Optional;

public interface GroupMemberRepository extends JpaRepository<GroupMember, Long> {

    List<GroupMember> findByUserOrderByJoinedAtDesc(AppUser user);

    List<GroupMember> findByGroupOrderByJoinedAtAsc(UserGroup group);

    Optional<GroupMember> findByGroupAndUser(UserGroup group, AppUser user);

    boolean existsByGroupAndUser(UserGroup group, AppUser user);

    long countByGroup(UserGroup group);
}
