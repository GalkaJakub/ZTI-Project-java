package wsp.controller;

import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import wsp.dto.UpdateUserRequest;
import wsp.dto.UserResponse;
import wsp.service.UserService;

/**
 * Kontroler REST udostępniający endpointy profilu aktualnie uwierzytelnionego użytkownika.
 */
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    /**
     * Tworzy kontroler profilu użytkownika.
     *
     * @param userService serwis obsługujący dane aktualnego użytkownika
     */
    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Zwraca dane profilu aktualnego użytkownika.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @return profil aktualnego użytkownika
     */
    @GetMapping("/me")
    public UserResponse getCurrentUser(Authentication authentication) {
        return userService.getCurrentUser(authentication.getName());
    }

    /**
     * Aktualizuje dane profilu aktualnego użytkownika.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param request dane aktualizacji profilu
     * @return zaktualizowany profil użytkownika
     */
    @PutMapping("/me")
    public UserResponse updateCurrentUser(Authentication authentication, @Valid @RequestBody UpdateUserRequest request)
    {
        return userService.updateCurrentUser(authentication.getName(), request);
    }
}
