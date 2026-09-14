//        return "CyberPlus";

package cyberpulse.common.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class TestController {

    private static final Logger log =
            LoggerFactory.getLogger(TestController.class);

    @GetMapping("/api/test")
    public Map<String, String> test() {

        log.info("CyberPulse test endpoint called");

        return Map.of(
                "status", "success",
                "message", "CyberPulse API is working"
        );
    }
}