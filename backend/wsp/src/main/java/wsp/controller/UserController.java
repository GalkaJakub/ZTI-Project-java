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
 * REST controller exposing endpoints for the currently authenticated user.
 */
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Returns profile data of the current user.
     *
     * @param authentication Spring Security authentication containing user email
     * @return current user profile
     */
    @GetMapping("/me")
    public UserResponse getCurrentUser(Authentication authentication) {
        return userService.getCurrentUser(authentication.getName());
    }

    /**
     * Updates profile data of the current user.
     *
     * @param authentication Spring Security authentication containing user email
     * @param request profile update data
     * @return updated user profile
     */
    @PutMapping("/me")
    public UserResponse updateCurrentUser(Authentication authentication, @Valid @RequestBody UpdateUserRequest request)
    {
        return userService.updateCurrentUser(authentication.getName(), request);
    }
}
