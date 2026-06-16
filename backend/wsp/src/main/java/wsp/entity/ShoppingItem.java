package wsp.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

/**
 * Encja produktu znajdującego się na grupowej liście zakupów.
 */
@Entity
@Table(name = "shopping_items")
@Getter
@Setter
public class ShoppingItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String quantity;

    @Column(nullable = false)
    private boolean bought = false;

    @ManyToOne(optional = false)
    @JoinColumn(name = "group_id", nullable = false)
    private UserGroup group;
}
