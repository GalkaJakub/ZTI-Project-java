package wsp.controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Prosty publiczny kontroler używany do ręcznego sprawdzenia działania API.
 */
@RestController
public class TestController {

    /**
     * Zwraca komunikat statusowy dla ręcznych testów połączenia.
     *
     * @return statyczny komunikat statusu API
     */
    @GetMapping("/api/hello")
    public String hello() {
        return "API works";
    }
}
