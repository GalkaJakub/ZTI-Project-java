package wsp.aop;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;
import wsp.entity.AuditLog;
import wsp.repository.AuditLogRepository;

import java.lang.reflect.Method;

/**
 * Aspekt Spring AOP zapisujący wpisy audytu po poprawnym zakończeniu oznaczonych metod serwisowych.
 */
@Aspect
@Component
public class AuditAspect {

    private final AuditLogRepository auditLogRepository;

    /**
     * Tworzy aspekt audytu z repozytorium wpisów audytowych.
     *
     * @param auditLogRepository repozytorium zapisujące wpisy audytu
     */
    public AuditAspect(AuditLogRepository auditLogRepository) {
        this.auditLogRepository = auditLogRepository;
    }

    /**
     * Tworzy i zapisuje wpis audytu na podstawie metadanych z adnotacji oraz argumentów metody.
     *
     * @param joinPoint punkt połączenia metody serwisowej
     * @param auditable konfiguracja audytu z adnotacji
     * @param result wynik zwrócony przez metodę serwisową
     */
    @AfterReturning(pointcut = "@annotation(auditable)", returning = "result")
    public void saveAuditLog(JoinPoint joinPoint, Auditable auditable, Object result) {
        AuditLog log = new AuditLog();
        log.setAction(auditable.action());
        log.setEntityType(auditable.entityType());
        log.setEntityId(resolveEntityId(joinPoint, auditable, result));
        log.setGroupId(resolveGroupId(joinPoint, result, auditable.groupIdArg()));
        log.setActorEmail(resolveActorEmail(joinPoint));

        auditLogRepository.save(log);
    }

    private Long resolveEntityId(JoinPoint joinPoint, Auditable auditable, Object result) {
        Long resultId = readLongProperty(result, "id");
        if (resultId != null) {
            return resultId;
        }

        if (!auditable.entityIdArg().isBlank()) {
            Long argumentId = readLongArgument(joinPoint, auditable.entityIdArg());
            if (argumentId != null) {
                return argumentId;
            }
        }

        return readLastLongArgument(joinPoint);
    }

    private Long resolveGroupId(JoinPoint joinPoint, Object result, String groupIdArg) {
        Long resultGroupId = readLongProperty(result, "groupId");
        if (resultGroupId != null) {
            return resultGroupId;
        }

        Long argumentGroupId = readLongArgument(joinPoint, groupIdArg);
        if (argumentGroupId != null) {
            return argumentGroupId;
        }

        return readLongArgumentAt(joinPoint, 1);
    }

    private String resolveActorEmail(JoinPoint joinPoint) {
        Object[] arguments = joinPoint.getArgs();
        if (arguments.length > 0 && arguments[0] instanceof String email) {
            return email;
        }

        return null;
    }

    private Long readLongArgument(JoinPoint joinPoint, String argumentName) {
        if (argumentName.isBlank() || !(joinPoint.getSignature() instanceof MethodSignature signature)) {
            return null;
        }

        String[] parameterNames = signature.getParameterNames();
        Object[] arguments = joinPoint.getArgs();
        for (int i = 0; i < parameterNames.length && i < arguments.length; i++) {
            if (argumentName.equals(parameterNames[i]) && arguments[i] instanceof Long value) {
                return value;
            }
        }

        return null;
    }

    private Long readLongArgumentAt(JoinPoint joinPoint, int index) {
        Object[] arguments = joinPoint.getArgs();
        if (index >= 0 && index < arguments.length && arguments[index] instanceof Long value) {
            return value;
        }

        return null;
    }

    private Long readLastLongArgument(JoinPoint joinPoint) {
        Object[] arguments = joinPoint.getArgs();
        for (int i = arguments.length - 1; i >= 0; i--) {
            if (arguments[i] instanceof Long value) {
                return value;
            }
        }

        return null;
    }

    private Long readLongProperty(Object object, String propertyName) {
        if (object == null) {
            return null;
        }

        try {
            Method accessor = object.getClass().getMethod(propertyName);
            Object value = accessor.invoke(object);
            return value instanceof Long id ? id : null;
        } catch (ReflectiveOperationException ignored) {
            return null;
        }
    }
}
