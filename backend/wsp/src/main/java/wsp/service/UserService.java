package wsp.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import wsp.dto.UpdateUserRequest;
import wsp.dto.UserResponse;
import wsp.entity.AppUser;
import wsp.repository.UserRepository;

/**
 * Serwis obsługujący profil aktualnie zalogowanego użytkownika.
 */
@Service
public class UserService {

    private final UserRepository userRepository;

    /**
     * Tworzy serwis profilu użytkownika.
     *
     * @param userRepository repozytorium użytkowników
     */
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    /**
     * Pobiera dane użytkownika na podstawie adresu e-mail z tokena JWT.
     *
     * @param email adres e-mail aktualnego użytkownika
     * @return dane profilu użytkownika
     */
    public UserResponse getCurrentUser(String email) {
        return UserResponse.fromEntity(findByEmail(email));
    }

    /**
     * Aktualizuje nazwę wyświetlaną aktualnego użytkownika.
     *
     * @param email adres e-mail aktualnego użytkownika
     * @param request dane aktualizacji profilu
     * @return zaktualizowany profil użytkownika
     */
    @Transactional
    public UserResponse updateCurrentUser(String email, UpdateUserRequest request) {
        AppUser user = findByEmail(email);
        user.setDisplayName(request.displayName().trim());
        return UserResponse.fromEntity(user);
    }

    private AppUser findByEmail(String email) {
        return userRepository.findByEmail(email).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }
}
