package cyberpulse.common.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@Slf4j
@RestController
public class TestController {

    @GetMapping("/api/test")
    public Map<String, String> test() {

        log.info("CyberPulse test endpoint called");

        return Map.of(
                "status", "success",
                "message", "CyberPulse API is working"
        );

//        return "CyberPlus";
    }
}