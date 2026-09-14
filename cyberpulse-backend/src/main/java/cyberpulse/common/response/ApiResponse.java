package cyberpulse.common.response;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
public class ApiResponse<T> {

    private boolean success;

    private String message;

    private T data;

    private Instant timestamp;
}