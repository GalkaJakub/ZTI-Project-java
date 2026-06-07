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
 * REST controller responsible for user registration, login and logout endpoints.
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService)
    {
        this.authService = authService;
    }

    /**
     * Registers a new user account and returns a JWT session response.
     *
     * @param request registration form data
     * @return authentication response with bearer token and user data
     */
    @PostMapping("/register")
    public AuthResponse register(@Valid @RequestBody RegisterRequest request)
    {
        return authService.register(request);
    }

    /**
     * Authenticates an existing user and returns a JWT session response.
     *
     * @param request login credentials
     * @return authentication response with bearer token and user data
     */
    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request)
    {
        return authService.login(request);
    }

    /**
     * Stateless logout endpoint used by the client after clearing the local token.
     *
     * @return empty 204 response
     */
    @PostMapping("/logout")
    public ResponseEntity<Void> logout()
    {
        return ResponseEntity.noContent().build();
    }
}
