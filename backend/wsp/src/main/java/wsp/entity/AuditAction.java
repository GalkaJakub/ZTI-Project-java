package wsp.entity;

/**
 * Typy operacji biznesowych zapisywanych w dzienniku audytu.
 */
public enum AuditAction {
    /** Utworzenie nowego obiektu biznesowego. */
    CREATE,
    /** Aktualizacja istniejącego obiektu biznesowego. */
    UPDATE,
    /** Usunięcie obiektu biznesowego. */
    DELETE,
    /** Oznaczenie produktu zakupowego jako kupionego lub niekupionego. */
    MARK_AS_PURCHASED
}
