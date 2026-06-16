package wsp.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;

import java.util.List;

/**
 * Żądanie utworzenia lub aktualizacji przepisu wraz ze składnikami.
 *
 * @param title tytuł przepisu
 * @param description opcjonalny krótki opis przepisu
 * @param instructions instrukcja przygotowania przepisu
 * @param ingredients lista składników przepisu
 */
public record CreateRecipeRequest(
        @NotBlank(message = "Title cannot be blank")
        String title,

        String description,

        @NotBlank(message = "Instructions cannot be blank")
        String instructions,

        List<@Valid CreateRecipeIngredientRequest> ingredients
) {
}
