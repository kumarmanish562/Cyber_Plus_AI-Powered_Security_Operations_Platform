package cyberpulse.common.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.List;

@Getter
@Builder
@AllArgsConstructor
public class ErrorResponse {

    private Instant timestamp;
    private int status;
    private String code;
    private String message;
    private String path;
    private List<String> details;
}