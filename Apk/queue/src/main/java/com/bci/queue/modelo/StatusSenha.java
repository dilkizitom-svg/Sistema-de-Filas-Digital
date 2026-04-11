package com.bci.queue.modelo;

public enum StatusSenha {

    ESPERANDO,          // Cliente tirou a senha, está na fila
    EM_ATENDIMENTO,     // Senha foi chamada, cliente está no balcão
    ATENDIDO,           // Atendimento concluído
    CANCELADO           // Cliente desistiu ou senha expirou
}
