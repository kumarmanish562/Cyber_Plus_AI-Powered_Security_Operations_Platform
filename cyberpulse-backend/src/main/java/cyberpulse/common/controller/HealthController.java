package cyberpulse.common.controller;


import cyberpulse.common.response.ApiResponse;
import cyberpulse.common.validation.TestRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;

@RestController
@RequestMapping("/api/health")
public class HealthController {

    @GetMapping
    public ResponseEntity<ApiResponse<String>> health() {

        ApiResponse<String> response = ApiResponse.<String>builder()
                .success(true)
                .message("CyberPulse backend is running")
                .data("UP")
                .timestamp(Instant.now())
                .build();

        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<?> test(
            @Valid @RequestBody TestRequest request) {

        return ResponseEntity.ok(request);
    }
}
