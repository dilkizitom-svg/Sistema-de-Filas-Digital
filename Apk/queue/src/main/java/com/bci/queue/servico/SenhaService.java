package com.bci.queue.servico;

import com.bci.queue.modelo.Senha;
import com.bci.queue.modelo.StatusSenha;
import com.bci.queue.repositorio.SenhaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class SenhaService {

    private static final int MINUTOS_POR_ATENDIMENTO = 5;
    private final SenhaRepository repo;

    public SenhaService(SenhaRepository repo) {
        this.repo = repo;
    }

    // ── Gerar senha — numeração independente por serviço ──────────
    @Transactional
   public Senha gerarSenha(String servico) {
    final String servicoNorm = servico.toUpperCase().trim();
    int numero = repo.findMaxNumeroSenhaByServico(servicoNorm) + 1;
    long posicao = repo.countByStatusAndServico(StatusSenha.ESPERANDO, servicoNorm) + 1;

    Senha senha = new Senha();
    senha.setNumeroSenha(numero);
    senha.setServico(servicoNorm);
    senha.setStatus(StatusSenha.ESPERANDO);
    senha.setHorarioCriacao(LocalDateTime.now());
    senha.setPosicaoFila((int) posicao);
    senha.setTempoEstimadoEspera((int) posicao * MINUTOS_POR_ATENDIMENTO);

    return repo.save(senha);
}

    // ── Listar fila por serviço ────────────────────────────────────
    public List<Senha> listarFilaPorServico(String servico) {
        return repo.findByStatusAndServicoOrderByHorarioCriacaoAsc(
            StatusSenha.ESPERANDO, servico
        );
    }

    // ── Listar todas as filas (ecrã geral) ────────────────────────
    public List<Senha> listarTodasFilas() {
        return repo.findByStatusOrderByServicoAscHorarioCriacaoAsc(StatusSenha.ESPERANDO);
    }

    // ── Chamar próxima senha de um serviço ────────────────────────
    @Transactional
   public Senha chamarProximaSenha(String balcao, String servico) {
    final String servicoNorm = servico.toUpperCase().trim();
    Senha proxima = repo.findFirstByStatusAndServicoOrderByHorarioCriacaoAsc(
        StatusSenha.ESPERANDO, servicoNorm
    ).orElseThrow(() -> new RuntimeException(
        "A fila de " + servicoNorm + " está vazia."
    ));

    proxima.setStatus(StatusSenha.EM_ATENDIMENTO);
    proxima.setBalcao(balcao);
    proxima.setHorarioInicioAtendimento(LocalDateTime.now());
    repo.save(proxima);

    actualizarEstimativasDaFila(servicoNorm);
    return proxima;
}

    // ── Marcar como atendido ──────────────────────────────────────
    @Transactional
    public Senha marcarComoAtendido(Long id) {
        Senha senha = buscarPorId(id);
        if (senha.getStatus() != StatusSenha.EM_ATENDIMENTO) {
            throw new RuntimeException("Só é possível encerrar senhas EM_ATENDIMENTO.");
        }
        senha.setStatus(StatusSenha.ATENDIDO);
        senha.setHorarioFimAtendimento(LocalDateTime.now());
        return repo.save(senha);
    }

    // ── Cancelar senha ────────────────────────────────────────────
    @Transactional
    public Senha cancelarSenha(Long id) {
        Senha senha = buscarPorId(id);
        if (senha.getStatus() == StatusSenha.ATENDIDO) {
            throw new RuntimeException("Não é possível cancelar uma senha já atendida.");
        }
        senha.setStatus(StatusSenha.CANCELADO);
        repo.save(senha);
        actualizarEstimativasDaFila(senha.getServico());
        return senha;
    }

    // ── Consultar posição ─────────────────────────────────────────
    public Senha consultarPosicao(Long id) {
        return buscarPorId(id);
    }

    // ── Recalcular posições da fila de um serviço ─────────────────
    private void actualizarEstimativasDaFila(String servico) {
        List<Senha> fila = repo.findByStatusAndServicoOrderByHorarioCriacaoAsc(
            StatusSenha.ESPERANDO, servico
        );
        for (int i = 0; i < fila.size(); i++) {
            Senha s = fila.get(i);
            s.setPosicaoFila(i + 1);
            s.setTempoEstimadoEspera((i + 1) * MINUTOS_POR_ATENDIMENTO);
            repo.save(s);
        }
    }

    // ── Buscar por ID ─────────────────────────────────────────────
    public Senha buscarPorId(Long id) {
        return repo.findById(id).orElseThrow(() ->
            new RuntimeException("Senha com ID " + id + " não encontrada.")
        );
    }
}