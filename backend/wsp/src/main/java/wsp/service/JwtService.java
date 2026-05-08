package wsp.service;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import wsp.entity.AppUser;

import java.util.Date;
import java.util.Optional;

@Service
public class JwtService {

    private final Algorithm algorithm;
    private final long expirationMs;

    public JwtService(@Value("${app.security.jwt.secret}") String secret,
                      @Value("${app.security.jwt.expiration-ms:86400000}") long expirationMs) {
        this.algorithm = Algorithm.HMAC256(secret);
        this.expirationMs = expirationMs;
    }

    public String generateToken(AppUser user) {
        return JWT.create().withSubject(user.getEmail()).withExpiresAt(new Date(System.currentTimeMillis() + expirationMs)).sign(algorithm);
    }

    public Optional<String> extractSubject(String token) {
        try {
            String email = JWT.require(algorithm).build().verify(token).getSubject();
            return email.isBlank() ? Optional.empty() : Optional.of(email);
        } catch (JWTVerificationException exception) {
            return Optional.empty();
        }
    }
}
