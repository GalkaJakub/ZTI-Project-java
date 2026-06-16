package wsp.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.AppUser;

import java.util.Optional;

/**
 * Repozytorium kont użytkowników aplikacji.
 */
public interface UserRepository extends JpaRepository<AppUser, Long> {

    /**
     * Wyszukuje użytkownika po adresie e-mail.
     *
     * @param email adres e-mail użytkownika
     * @return użytkownik, jeśli istnieje
     */
    Optional<AppUser> findByEmail(String email);

    /**
     * Sprawdza, czy istnieje konto o podanym adresie e-mail.
     *
     * @param email adres e-mail
     * @return true, jeśli konto istnieje
     */
    boolean existsByEmail(String email);
}
