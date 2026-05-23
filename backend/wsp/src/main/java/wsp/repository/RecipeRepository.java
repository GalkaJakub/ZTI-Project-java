package wsp.repository;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.Recipe;
import wsp.entity.UserGroup;

import java.util.List;
import java.util.Optional;

public interface RecipeRepository extends JpaRepository<Recipe, Long> {

    @EntityGraph(attributePaths = "ingredients")
    List<Recipe> findByGroupOrderByTitleAsc(UserGroup group);

    @EntityGraph(attributePaths = "ingredients")
    Optional<Recipe> findByIdAndGroup(Long id, UserGroup group);
}
