package com.bci.queue.repositorio;

import com.bci.queue.modelo.Senha;
import com.bci.queue.modelo.StatusSenha;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SenhaRepository extends JpaRepository<Senha, Long> {

    // Fila por serviço — só ESPERANDO
    List<Senha> findByStatusAndServicoOrderByHorarioCriacaoAsc(StatusSenha status, String servico);

    // Próxima senha de um serviço específico
    Optional<Senha> findFirstByStatusAndServicoOrderByHorarioCriacaoAsc(StatusSenha status, String servico);

    // Contar por status e serviço
    long countByStatusAndServico(StatusSenha status, String servico);

    // Máximo número de senha por serviço — para numeração independente
    @Query("SELECT COALESCE(MAX(s.numeroSenha), 0) FROM Senha s WHERE s.servico = :servico")
    int findMaxNumeroSenhaByServico(@Param("servico") String servico);

    // Todas as ESPERANDO (para o ecrã geral)
    List<Senha> findByStatusOrderByServicoAscHorarioCriacaoAsc(StatusSenha status);
}