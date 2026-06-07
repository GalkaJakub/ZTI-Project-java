package wsp.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import wsp.dto.UpdateUserRequest;
import wsp.dto.UserResponse;
import wsp.entity.AppUser;
import wsp.repository.UserRepository;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserResponse getCurrentUser(String email) {
        return UserResponse.fromEntity(findByEmail(email));
    }

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
