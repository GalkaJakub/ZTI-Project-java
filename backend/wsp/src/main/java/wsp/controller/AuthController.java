package wsp.controller;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import wsp.dto.AuthResponse;
import wsp.dto.LoginRequest;
import wsp.dto.RegisterRequest;
import wsp.service.AuthService;

/**
 * Kontroler REST odpowiedzialny za rejestrację, logowanie i wylogowanie użytkowników.
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    /**
     * Tworzy kontroler uwierzytelniania z wymaganym serwisem logowania.
     *
     * @param authService serwis obsługujący rejestrację i logowanie
     */
    public AuthController(AuthService authService)
    {
        this.authService = authService;
    }

    /**
     * Rejestruje nowe konto użytkownika i zwraca dane sesji JWT.
     *
     * @param request dane formularza rejestracji
     * @return odpowiedź uwierzytelniania z tokenem Bearer i danymi użytkownika
     */
    @PostMapping("/register")
    public AuthResponse register(@Valid @RequestBody RegisterRequest request)
    {
        return authService.register(request);
    }

    /**
     * Uwierzytelnia istniejącego użytkownika i zwraca dane sesji JWT.
     *
     * @param request dane logowania
     * @return odpowiedź uwierzytelniania z tokenem Bearer i danymi użytkownika
     */
    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request)
    {
        return authService.login(request);
    }

    /**
     * Bezstanowy endpoint wylogowania używany po usunięciu tokena po stronie klienta.
     *
     * @return pusta odpowiedź HTTP 204
     */
    @PostMapping("/logout")
    public ResponseEntity<Void> logout()
    {
        return ResponseEntity.noContent().build();
    }
}
