package wsp.entity;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Encja tygodniowego planu posiłków przypisanego do grupy.
 */
@Entity
@Table(
        name = "meal_plans",
        uniqueConstraints = @UniqueConstraint(columnNames = {"group_id", "week_start_date"})
)
@Getter
@Setter
public class MealPlan {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "week_start_date", nullable = false)
    private LocalDate weekStartDate;

    @ManyToOne(optional = false)
    @JoinColumn(name = "group_id", nullable = false)
    private UserGroup group;

    @OneToMany(mappedBy = "mealPlan", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PlannedMeal> meals = new ArrayList<>();
}
