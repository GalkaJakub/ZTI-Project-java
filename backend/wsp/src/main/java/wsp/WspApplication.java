package wsp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Entry point of the WSP Spring Boot backend application.
 */
@SpringBootApplication
public class WspApplication {

    /**
     * Starts the embedded application server and initializes the Spring context.
     *
     * @param args command line arguments passed to Spring Boot
     */
    public static void main(String[] args) {
        SpringApplication.run(WspApplication.class, args);
    }

}
