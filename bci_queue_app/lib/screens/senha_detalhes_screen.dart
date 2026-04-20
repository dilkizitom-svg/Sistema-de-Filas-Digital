import 'dart:async';
import 'package:flutter/material.dart';
import '../models/senha.dart';
import '../services/senha_service.dart';

class SenhaDetalhesScreen extends StatefulWidget {
  final Senha senha;
  final String nomeCliente;

  const SenhaDetalhesScreen({
    super.key,
    required this.senha,
    required this.nomeCliente,
  });

  @override
  State<SenhaDetalhesScreen> createState() => _SenhaDetalhesScreenState();
}

class _SenhaDetalhesScreenState extends State<SenhaDetalhesScreen> {
  late Senha _senhaActual;
  final SenhaService _service = SenhaService();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _senhaActual = widget.senha;
    
    // Iniciar actualização periódica se a senha não estiver finalizada
    if (_senhaActual.status == 'ESPERANDO' || _senhaActual.status == 'EM_ATENDIMENTO') {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) => _actualizarDados());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _actualizarDados() async {
    try {
      final novaSenha = await _service.consultarPosicao(_senhaActual.id);
      if (mounted) {
        setState(() {
          _senhaActual = novaSenha;
        });
        
        // Se a senha foi concluída ou cancelada, parar o timer
        if (novaSenha.status == 'ATENDIDO' || novaSenha.status == 'CANCELADO') {
          _timer?.cancel();
        }
      }
    } catch (_) {
      // Erro na ligação, mantém os dados actuais
    }
  }

  String _formatarHora(String horario) {
    try {
      final dt = DateTime.parse(horario);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }

  String _formatarData(String horario) {
    try {
      final dt = DateTime.parse(horario);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return '--/--/----';
    }
  }

  Color _corEstado(String status) {
    switch (status) {
      case 'ESPERANDO':      return const Color(0xFFFF9100);
      case 'EM_ATENDIMENTO': return const Color(0xFF00C853);
      case 'ATENDIDO':       return const Color(0xFF888888);
      case 'CANCELADO':      return const Color(0xFFE8001D);
      default:               return const Color(0xFF888888);
    }
  }

  String _textoEstado(String status) {
    switch (status) {
      case 'ESPERANDO':      return 'Em Espera';
      case 'EM_ATENDIMENTO': return 'Em Atendimento';
      case 'ATENDIDO':       return 'Atendido';
      case 'CANCELADO':      return 'Cancelado';
      default:               return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = _corEstado(_senhaActual.status);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: const Color(0xFFE8001D),
              child: const Text('BCI',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2)),
            ),
            const SizedBox(width: 10),
            const Text('Detalhes da Senha',
                style: TextStyle(fontSize: 16, color: Color(0xFF888888))),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF3A3A3A)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border.all(color: const Color(0xFF3A3A3A)),
              ),
              child: Column(
                children: [
                  const Text('SENHA', style: TextStyle(color: Color(0xFF888888), fontSize: 11, letterSpacing: 3)),
                  const SizedBox(height: 8),
                  Text(
                    _senhaActual.codigo,
                    style: const TextStyle(color: Color(0xFFE8001D), fontSize: 80, fontWeight: FontWeight.bold, height: 1),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: cor.withOpacity(0.1),
                      border: Border.all(color: cor.withOpacity(0.4)),
                    ),
                    child: Text(
                      _textoEstado(_senhaActual.status),
                      style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border.all(color: const Color(0xFF3A3A3A)),
              ),
              child: Column(
                children: [
                  _buildLinha('Cliente', widget.nomeCliente, Icons.person_outline),
                  _buildDivisor(),
                  _buildLinha('Serviço', _senhaActual.servico, Icons.category_outlined),
                  _buildDivisor(),
                  _buildLinha('Data', _formatarData(_senhaActual.horarioCriacao), Icons.calendar_today_outlined),
                  _buildDivisor(),
                  _buildLinha('Hora de emissão', _formatarHora(_senhaActual.horarioCriacao), Icons.access_time),
                  _buildDivisor(),
                  _buildLinha('Posição na fila',
                    _senhaActual.status == 'ESPERANDO' ? '${_senhaActual.posicaoFila}º lugar' : '—',
                    Icons.people_outline,
                  ),
                  _buildDivisor(),
                  _buildLinha('Tempo estimado',
                    _senhaActual.status == 'ESPERANDO' ? '~${_senhaActual.tempoEstimadoEspera} minutos' : '—',
                    Icons.timer_outlined,
                  ),
                  if (_senhaActual.balcao != null) ...[
                    _buildDivisor(),
                    _buildLinha('Balcão', _senhaActual.balcao!, Icons.desk_outlined),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8001D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: const Text('VOLTAR', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinha(String label, String valor, IconData icone) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icone, size: 18, color: const Color(0xFFE8001D)),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
          const Spacer(),
          Text(valor, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDivisor() {
    return Container(height: 1, color: const Color(0xFF2C2C2C));
  }
}
