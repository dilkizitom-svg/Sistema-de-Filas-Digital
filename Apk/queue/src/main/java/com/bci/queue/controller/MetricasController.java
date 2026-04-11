package com.bci.queue.controller;

import com.bci.queue.modelo.StatusSenha;
import com.bci.queue.repositorio.SenhaRepository;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

@RestController
@RequestMapping("/api/metricas")
@CrossOrigin(origins = "*")
public class MetricasController {

    private final SenhaRepository repo;

    public MetricasController(SenhaRepository repo) {
        this.repo = repo;
    }

    // ── Dashboard principal ───────────────────────────
    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> dashboard() {
        LocalDateTime inicioDia = LocalDate.now().atStartOfDay();
        LocalDateTime fimDia = LocalDate.now().atTime(LocalTime.MAX);

        List<com.bci.queue.modelo.Senha> todas = repo.findAll();
        List<com.bci.queue.modelo.Senha> hoje = todas.stream()
            .filter(s -> s.getHorarioCriacao().isAfter(inicioDia) &&
                        s.getHorarioCriacao().isBefore(fimDia))
            .toList();

        // Totais gerais hoje
        long totalHoje = hoje.size();
        long atendidosHoje = hoje.stream().filter(s -> s.getStatus() == StatusSenha.ATENDIDO).count();
        long canceladosHoje = hoje.stream().filter(s -> s.getStatus() == StatusSenha.CANCELADO).count();
        long emEsperaAgora = todas.stream().filter(s -> s.getStatus() == StatusSenha.ESPERANDO).count();
        long emAtendimentoAgora = todas.stream().filter(s -> s.getStatus() == StatusSenha.EM_ATENDIMENTO).count();

        // Por serviço
        long caixaHoje = hoje.stream().filter(s -> s.getServico().equals("CAIXA")).count();
        long atendimentoHoje = hoje.stream().filter(s -> s.getServico().equals("ATENDIMENTO")).count();
        long emEspera_Caixa = todas.stream().filter(s -> s.getStatus() == StatusSenha.ESPERANDO && s.getServico().equals("CAIXA")).count();
        long emEspera_Atendimento = todas.stream().filter(s -> s.getStatus() == StatusSenha.ESPERANDO && s.getServico().equals("ATENDIMENTO")).count();

        // Tempo médio de atendimento (senhas atendidas com hora início e fim)
        OptionalDouble tempoMedio = hoje.stream()
            .filter(s -> s.getStatus() == StatusSenha.ATENDIDO
                && s.getHorarioInicioAtendimento() != null
                && s.getHorarioFimAtendimento() != null)
            .mapToLong(s -> java.time.Duration.between(
                s.getHorarioInicioAtendimento(),
                s.getHorarioFimAtendimento()).toMinutes())
            .average();

        // Picos por hora (0-23)
        Map<Integer, Long> picosPorHora = new LinkedHashMap<>();
        for (int h = 7; h <= 18; h++) {
            final int hora = h;
            long count = hoje.stream()
                .filter(s -> s.getHorarioCriacao().getHour() == hora)
                .count();
            picosPorHora.put(hora, count);
        }

        Map<String, Object> resultado = new LinkedHashMap<>();
        resultado.put("totalHoje", totalHoje);
        resultado.put("atendidosHoje", atendidosHoje);
        resultado.put("canceladosHoje", canceladosHoje);
        resultado.put("emEsperaAgora", emEsperaAgora);
        resultado.put("emAtendimentoAgora", emAtendimentoAgora);
        resultado.put("caixaHoje", caixaHoje);
        resultado.put("atendimentoHoje", atendimentoHoje);
        resultado.put("emEspera_Caixa", emEspera_Caixa);
        resultado.put("emEspera_Atendimento", emEspera_Atendimento);
        resultado.put("tempoMedioMinutos", tempoMedio.isPresent() ? Math.round(tempoMedio.getAsDouble()) : 0);
        resultado.put("picosPorHora", picosPorHora);

        return ResponseEntity.ok(resultado);
    }

    // ── Histórico de atendimentos hoje ────────────────
    @GetMapping("/historico")
    public ResponseEntity<List<Map<String, Object>>> historico() {
        LocalDateTime inicioDia = LocalDate.now().atStartOfDay();

        List<Map<String, Object>> historico = repo.findAll().stream()
            .filter(s -> s.getHorarioCriacao().isAfter(inicioDia))
            .sorted(Comparator.comparing(com.bci.queue.modelo.Senha::getHorarioCriacao).reversed())
            .map(s -> {
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("id", s.getId());
                item.put("numeroSenha", s.getNumeroSenha());
                item.put("servico", s.getServico());
                item.put("status", s.getStatus().toString());
                item.put("horarioCriacao", s.getHorarioCriacao().toString());
                item.put("balcao", s.getBalcao());
                item.put("horarioInicioAtendimento", s.getHorarioInicioAtendimento() != null ? s.getHorarioInicioAtendimento().toString() : null);
                item.put("horarioFimAtendimento", s.getHorarioFimAtendimento() != null ? s.getHorarioFimAtendimento().toString() : null);
                return item;
            })
            .toList();

        return ResponseEntity.ok(historico);
    }

    // ── Cancelar senha (gestor) ───────────────────────
    @PutMapping("/senha/{id}/cancelar")
    public ResponseEntity<Map<String, Object>> cancelarSenha(@PathVariable Long id) {
        try {
            var senha = repo.findById(id).orElseThrow(() ->
                new RuntimeException("Senha não encontrada."));
            senha.setStatus(StatusSenha.CANCELADO);
            repo.save(senha);

            Map<String, Object> res = new LinkedHashMap<>();
            res.put("mensagem", "Senha " + senha.getNumeroSenha() + " cancelada pelo gestor.");
            res.put("id", id);
            return ResponseEntity.ok(res);
        } catch (RuntimeException e) {
            Map<String, Object> erro = new LinkedHashMap<>();
            erro.put("erro", e.getMessage());
            return ResponseEntity.status(404).body(erro);
        }
    }

    // ── Chamar senha manualmente (gestor) ─────────────
    @PutMapping("/senha/{id}/chamar")
    public ResponseEntity<Map<String, Object>> chamarManualmente(
            @PathVariable Long id,
            @RequestParam String balcao) {
        try {
            var senha = repo.findById(id).orElseThrow(() ->
                new RuntimeException("Senha não encontrada."));
            senha.setStatus(StatusSenha.EM_ATENDIMENTO);
            senha.setBalcao(balcao);
            senha.setHorarioInicioAtendimento(LocalDateTime.now());
            repo.save(senha);

            Map<String, Object> res = new LinkedHashMap<>();
            res.put("mensagem", "Senha " + senha.getNumeroSenha() + " chamada manualmente para " + balcao + ".");
            res.put("id", id);
            return ResponseEntity.ok(res);
        } catch (RuntimeException e) {
            Map<String, Object> erro = new LinkedHashMap<>();
            erro.put("erro", e.getMessage());
            return ResponseEntity.status(404).body(erro);
        }
    }

    // ── Listar todas as senhas activas (gestor) ───────
    @GetMapping("/fila/todas")
    public ResponseEntity<List<Map<String, Object>>> todasSenhasActivas() {
        List<Map<String, Object>> lista = repo.findAll().stream()
            .filter(s -> s.getStatus() == StatusSenha.ESPERANDO ||
                        s.getStatus() == StatusSenha.EM_ATENDIMENTO)
            .sorted(Comparator.comparing(com.bci.queue.modelo.Senha::getHorarioCriacao))
            .map(s -> {
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("id", s.getId());
                item.put("numeroSenha", s.getNumeroSenha());
                item.put("servico", s.getServico());
                item.put("status", s.getStatus().toString());
                item.put("horarioCriacao", s.getHorarioCriacao().toString());
                item.put("balcao", s.getBalcao());
                item.put("posicaoFila", s.getPosicaoFila());
                item.put("tempoEstimadoEspera", s.getTempoEstimadoEspera());
                return item;
            })
            .toList();

        return ResponseEntity.ok(lista);
    }

    // ── Reset da fila (modo demonstração) ────────────
@DeleteMapping("/reset")
public ResponseEntity<Map<String, Object>> resetFila() {
    List<com.bci.queue.modelo.Senha> activas = repo.findAll().stream()
        .filter(s -> s.getStatus() == StatusSenha.ESPERANDO ||
                    s.getStatus() == StatusSenha.EM_ATENDIMENTO)
        .toList();

    activas.forEach(s -> {
        s.setStatus(StatusSenha.CANCELADO);
        repo.save(s);
    });

    Map<String, Object> res = new LinkedHashMap<>();
    res.put("mensagem", "Fila resetada com sucesso. " + activas.size() + " senha(s) cancelada(s).");
    res.put("senhasCanceladas", activas.size());
    return ResponseEntity.ok(res);
}
}