package wsp.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.AppUser;
import wsp.entity.GroupMember;
import wsp.entity.UserGroup;

import java.util.List;
import java.util.Optional;

/**
 * Repozytorium członkostw użytkowników w grupach.
 */
public interface GroupMemberRepository extends JpaRepository<GroupMember, Long> {

    /**
     * Pobiera członkostwa użytkownika od najnowszych.
     *
     * @param user użytkownik
     * @return lista członkostw użytkownika
     */
    List<GroupMember> findByUserOrderByJoinedAtDesc(AppUser user);

    /**
     * Pobiera członków grupy od najstarszego członkostwa.
     *
     * @param group grupa
     * @return lista członkostw w grupie
     */
    List<GroupMember> findByGroupOrderByJoinedAtAsc(UserGroup group);

    /**
     * Wyszukuje członkostwo konkretnego użytkownika w konkretnej grupie.
     *
     * @param group grupa
     * @param user użytkownik
     * @return członkostwo, jeśli istnieje
     */
    Optional<GroupMember> findByGroupAndUser(UserGroup group, AppUser user);

    /**
     * Sprawdza, czy użytkownik należy do grupy.
     *
     * @param group grupa
     * @param user użytkownik
     * @return true, jeśli użytkownik jest członkiem grupy
     */
    boolean existsByGroupAndUser(UserGroup group, AppUser user);

    /**
     * Zlicza członków grupy.
     *
     * @param group grupa
     * @return liczba członkostw
     */
    long countByGroup(UserGroup group);
}
