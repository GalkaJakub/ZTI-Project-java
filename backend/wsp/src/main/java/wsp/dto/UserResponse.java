package wsp.dto;

import wsp.entity.AppUser;

/**
 * Odpowiedź opisująca użytkownika aplikacji.
 *
 * @param id identyfikator użytkownika
 * @param email adres e-mail użytkownika
 * @param displayName nazwa wyświetlana użytkownika
 */
public record UserResponse(
        Long id,
        String email,
        String displayName
) {

    /**
     * Tworzy DTO użytkownika z encji JPA.
     *
     * @param user encja użytkownika
     * @return odpowiedź z danymi użytkownika
     */
    public static UserResponse fromEntity(AppUser user) {
        return new UserResponse(
                user.getId(),
                user.getEmail(),
                user.getDisplayName()
        );
    }
}
