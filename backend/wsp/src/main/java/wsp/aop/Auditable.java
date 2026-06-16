package wsp.aop;

import wsp.entity.AuditAction;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Adnotacja oznaczająca metodę serwisową, której wykonanie ma zostać zapisane w audycie.
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Auditable {

    /**
     * Typ operacji wykonywanej przez oznaczoną metodę.
     *
     * @return akcja audytowa
     */
    AuditAction action();

    /**
     * Nazwa typu encji biznesowej, której dotyczy operacja.
     *
     * @return tekstowa nazwa encji
     */
    String entityType();

    /**
     * Nazwa argumentu metody zawierającego identyfikator encji.
     *
     * @return nazwa argumentu lub pusty tekst, jeśli identyfikator ma być pobrany z wyniku
     */
    String entityIdArg() default "";

    /**
     * Nazwa argumentu metody zawierającego identyfikator grupy.
     *
     * @return nazwa argumentu z identyfikatorem grupy
     */
    String groupIdArg() default "groupId";
}
