package wsp.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.UserGroup;

import java.util.Optional;

/**
 * Repozytorium grup użytkowników.
 */
public interface UserGroupRepository extends JpaRepository<UserGroup, Long> {

    /**
     * Wyszukuje grupę po kodzie zaproszenia bez uwzględniania wielkości liter.
     *
     * @param inviteCode kod zaproszenia
     * @return grupa, jeśli kod istnieje
     */
    Optional<UserGroup> findByInviteCodeIgnoreCase(String inviteCode);

    /**
     * Sprawdza, czy kod zaproszenia jest już używany.
     *
     * @param inviteCode kod zaproszenia
     * @return true, jeśli kod istnieje
     */
    boolean existsByInviteCode(String inviteCode);
}
