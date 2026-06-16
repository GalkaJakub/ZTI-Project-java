package wsp.repository;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.Recipe;
import wsp.entity.UserGroup;

import java.util.List;
import java.util.Optional;

/**
 * Repozytorium przepisów przypisanych do grup użytkowników.
 */
public interface RecipeRepository extends JpaRepository<Recipe, Long> {

    /**
     * Pobiera przepisy grupy posortowane alfabetycznie razem ze składnikami.
     *
     * @param group grupa właścicielska przepisów
     * @return lista przepisów grupy
     */
    @EntityGraph(attributePaths = "ingredients")
    List<Recipe> findByGroupOrderByTitleAsc(UserGroup group);

    /**
     * Wyszukuje przepis po identyfikatorze tylko w obrębie wskazanej grupy.
     *
     * @param id identyfikator przepisu
     * @param group grupa właścicielska przepisu
     * @return przepis, jeśli należy do grupy
     */
    @EntityGraph(attributePaths = "ingredients")
    Optional<Recipe> findByIdAndGroup(Long id, UserGroup group);
}
