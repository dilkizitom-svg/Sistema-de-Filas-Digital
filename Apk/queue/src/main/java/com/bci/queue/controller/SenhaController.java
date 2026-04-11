package com.bci.queue.controller;

import com.bci.queue.modelo.Senha;
import com.bci.queue.servico.SenhaService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class SenhaController {

    private final SenhaService service;

    public SenhaController(SenhaService service) {
        this.service = service;
    }

    // Gerar nova senha
    @PostMapping("/senha")
    public ResponseEntity<Senha> gerarSenha(@RequestParam String servico) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.gerarSenha(servico));
    }

    // Listar fila por serviço
    @GetMapping("/fila")
    public ResponseEntity<List<Senha>> listarFila(@RequestParam(required = false) String servico) {
        if (servico != null && !servico.isEmpty()) {
            return ResponseEntity.ok(service.listarFilaPorServico(servico));
        }
        return ResponseEntity.ok(service.listarTodasFilas());
    }

    // Chamar próxima senha — agora exige serviço
    @PostMapping("/fila/chamar")
    public ResponseEntity<Senha> chamarProxima(
            @RequestParam String balcao,
            @RequestParam String servico) {
        return ResponseEntity.ok(service.chamarProximaSenha(balcao, servico));
    }

    // Marcar como atendido
    @PutMapping("/senha/{id}/atendido")
    public ResponseEntity<Senha> marcarAtendido(@PathVariable Long id) {
        return ResponseEntity.ok(service.marcarComoAtendido(id));
    }

    // Cancelar senha
    @PutMapping("/senha/{id}/cancelar")
    public ResponseEntity<Senha> cancelar(@PathVariable Long id) {
        return ResponseEntity.ok(service.cancelarSenha(id));
    }

    // Consultar posição
    @GetMapping("/senha/{id}/posicao")
    public ResponseEntity<Senha> posicao(@PathVariable Long id) {
        return ResponseEntity.ok(service.consultarPosicao(id));
    }
}