package com.bci.queue.modelo;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "senhas")
public class Senha {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Integer numeroSenha;

    @Column(nullable = false)
    private String servico;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusSenha status;

    @Column(nullable = false)
    private LocalDateTime horarioCriacao;

    // ── Campos novos ──────────────────────────────────

    private String balcao;                          // ex: "Balcão 2"

    private Integer posicaoFila;                    // posição actual na fila

    private Integer tempoEstimadoEspera;            // em minutos

    private LocalDateTime horarioInicioAtendimento; // quando começou a ser atendida

    private LocalDateTime horarioFimAtendimento;    // quando terminou

    // ── Construtor vazio (obrigatório para o JPA) ─────

    public Senha() {}

    // ── Getters e Setters ─────────────────────────────

    public Long getId() { return id; }

    public Integer getNumeroSenha() { return numeroSenha; }
    public void setNumeroSenha(Integer numeroSenha) { this.numeroSenha = numeroSenha; }

    public String getServico() { return servico; }
    public void setServico(String servico) { this.servico = servico; }

    public StatusSenha getStatus() { return status; }
    public void setStatus(StatusSenha status) { this.status = status; }

    public LocalDateTime getHorarioCriacao() { return horarioCriacao; }
    public void setHorarioCriacao(LocalDateTime horarioCriacao) { this.horarioCriacao = horarioCriacao; }

    public String getBalcao() { return balcao; }
    public void setBalcao(String balcao) { this.balcao = balcao; }

    public Integer getPosicaoFila() { return posicaoFila; }
    public void setPosicaoFila(Integer posicaoFila) { this.posicaoFila = posicaoFila; }

    public Integer getTempoEstimadoEspera() { return tempoEstimadoEspera; }
    public void setTempoEstimadoEspera(Integer tempoEstimadoEspera) { this.tempoEstimadoEspera = tempoEstimadoEspera; }

    public LocalDateTime getHorarioInicioAtendimento() { return horarioInicioAtendimento; }
    public void setHorarioInicioAtendimento(LocalDateTime h) { this.horarioInicioAtendimento = h; }

    public LocalDateTime getHorarioFimAtendimento() { return horarioFimAtendimento; }
    public void setHorarioFimAtendimento(LocalDateTime h) { this.horarioFimAtendimento = h; }
}