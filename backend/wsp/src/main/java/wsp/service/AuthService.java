package wsp.service;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import wsp.dto.AuthResponse;
import wsp.dto.LoginRequest;
import wsp.dto.RegisterRequest;
import wsp.dto.UserResponse;
import wsp.entity.AppUser;
import wsp.repository.UserRepository;

import java.util.Locale;

/**
 * Serwis obsługujący rejestrację, logowanie oraz tworzenie odpowiedzi sesji JWT.
 */
@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    /**
     * Tworzy serwis uwierzytelniania z repozytorium użytkowników, enkoderem haseł i obsługą JWT.
     *
     * @param userRepository repozytorium użytkowników
     * @param passwordEncoder enkoder haseł
     * @param jwtService serwis generujący tokeny JWT
     */
    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtService jwtService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    /**
     * Rejestruje użytkownika po wcześniejszej normalizacji adresu e-mail.
     *
     * @param request dane rejestracyjne użytkownika
     * @return dane sesji wraz z tokenem JWT
     */
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String email = normalizeEmail(request.email());
        if (userRepository.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "User with this email already exists");
        }

        AppUser user = new AppUser();
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setDisplayName(request.displayName().trim());

        AppUser savedUser = userRepository.save(user);
        return createAuthResponse(savedUser);
    }

    /**
     * Loguje użytkownika na podstawie adresu e-mail i hasła.
     *
     * @param request dane logowania
     * @return dane sesji wraz z tokenem JWT
     */
    public AuthResponse login(LoginRequest request) {
        String email = normalizeEmail(request.email());
        AppUser user = userRepository.findByEmail(email).orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password"));

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password");
        }

        return createAuthResponse(user);
    }

    private AuthResponse createAuthResponse(AppUser user) {
        return new AuthResponse("Bearer", jwtService.generateToken(user), UserResponse.fromEntity(user));
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
