package wsp.controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Simple public controller used to verify that the API is running.
 */
@RestController
public class TestController {

    /**
     * Returns a health-check style message for manual tests.
     *
     * @return static API status message
     */
    @GetMapping("/api/hello")
    public String hello() {
        return "API works";
    }
}
