package wsp.repository;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.Recipe;

import java.util.List;
import java.util.Optional;

public interface RecipeRepository extends JpaRepository<Recipe, Long> {

    @EntityGraph(attributePaths = "ingredients")
    List<Recipe> findAllByOrderByTitleAsc();

    @EntityGraph(attributePaths = "ingredients")
    Optional<Recipe> findWithIngredientsById(Long id);
}
