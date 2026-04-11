package com.bci.queue.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

// Limita o handler apenas aos controllers da nossa API
@RestControllerAdvice(basePackages = "com.bci.queue.controller")
public class GlobalExceptionHandler {

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, Object>> handleRuntimeException(RuntimeException ex) {

        HttpStatus status;
        String mensagem = ex.getMessage();

        if (mensagem != null && mensagem.contains("não encontrada")) {
            status = HttpStatus.NOT_FOUND;
        } else if (mensagem != null && mensagem.contains("vazia")) {
            status = HttpStatus.NOT_FOUND;
        } else if (mensagem != null && (mensagem.contains("Só é possível") ||
                   mensagem.contains("Não é possível"))) {
            status = HttpStatus.BAD_REQUEST;
        } else {
            status = HttpStatus.INTERNAL_SERVER_ERROR;
        }

        Map<String, Object> erro = new HashMap<>();
        erro.put("timestamp", LocalDateTime.now().toString());
        erro.put("status", status.value());
        erro.put("erro", status.getReasonPhrase());
        erro.put("mensagem", mensagem);

        return ResponseEntity.status(status).body(erro);
    }
}