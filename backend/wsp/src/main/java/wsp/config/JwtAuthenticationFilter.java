package wsp.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import wsp.entity.AppUser;
import wsp.repository.UserRepository;
import wsp.service.JwtService;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

/**
 * Filtr bezpieczeństwa odczytujący token JWT z nagłówka Authorization i ustawiający kontekst użytkownika.
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String BEARER_PREFIX = "Bearer ";

    private final JwtService jwtService;
    private final UserRepository userRepository;

    /**
     * Tworzy filtr JWT z serwisem tokenów i repozytorium użytkowników.
     *
     * @param jwtService serwis walidujący tokeny JWT
     * @param userRepository repozytorium użytkowników aplikacji
     */
    public JwtAuthenticationFilter(JwtService jwtService, UserRepository userRepository) {
        this.jwtService = jwtService;
        this.userRepository = userRepository;
    }

    /**
     * Obsługuje pojedyncze żądanie HTTP i próbuje uwierzytelnić użytkownika na podstawie tokena Bearer.
     *
     * @param request żądanie HTTP
     * @param response odpowiedź HTTP
     * @param filterChain łańcuch filtrów Spring Security
     * @throws ServletException gdy filtr nie może przetworzyć żądania
     * @throws IOException gdy wystąpi błąd wejścia-wyjścia
     */
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException
    {
        String authorizationHeader = request.getHeader(HttpHeaders.AUTHORIZATION);

        if (authorizationHeader != null && authorizationHeader.startsWith(BEARER_PREFIX) && SecurityContextHolder.getContext().getAuthentication() == null) {
            authenticate(request, authorizationHeader.substring(BEARER_PREFIX.length()));
        }

        filterChain.doFilter(request, response);
    }

    private void authenticate(HttpServletRequest request, String token) {
        Optional<String> email = jwtService.extractSubject(token);
        if (email.isEmpty()) {
            return;
        }

        Optional<AppUser> userOptional = userRepository.findByEmail(email.get());
        if (userOptional.isEmpty()) {
            return;
        }

        AppUser user = userOptional.get();
        UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(user.getEmail(), null, List.of());
        SecurityContextHolder.getContext().setAuthentication(authentication);
    }
}
