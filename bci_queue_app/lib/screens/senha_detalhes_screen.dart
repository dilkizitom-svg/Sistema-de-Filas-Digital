import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
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
  bool _carregando = false;
  
  // Flags para evitar notificações repetidas
  bool _notificacaoVezPertoEnviada = false;
  bool _notificacaoChamadaEnviada = false;

  @override
  void initState() {
    super.initState();
    _senhaActual = widget.senha;
    _iniciarPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_senhaActual.status == 'ESPERANDO' || _senhaActual.status == 'EM_ATENDIMENTO') {
        _actualizarDados(silencioso: true);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _actualizarDados({bool silencioso = false}) async {
    if (!mounted) return;
    if (!silencioso) setState(() => _carregando = true);

    try {
      final novaSenha = await _service.consultarPosicao(_senhaActual.id);
      
      // ── Verificar Notificações em Tempo Real ───────────
      final posicao = novaSenha.posicaoFila ?? 99;
      if (posicao <= 2 && novaSenha.status == 'ESPERANDO' && !_notificacaoVezPertoEnviada) {
        _enviarNotificacao('A tua vez está a chegar! ⏳', 'Senha ${novaSenha.codigo}: Faltam cerca de ${posicao * 5} min.');
        _notificacaoVezPertoEnviada = true;
      }
      
      if (novaSenha.status == 'EM_ATENDIMENTO' && !_notificacaoChamadaEnviada) {
        _enviarNotificacao('🔔 É a tua vez!', 'Senha ${novaSenha.codigo}: Dirija-se ao balcão ${novaSenha.balcao ?? ""}.');
        _notificacaoChamadaEnviada = true;
      }

      if (mounted) {
        setState(() {
          _senhaActual = novaSenha;
          _carregando = false;
        });

        if (novaSenha.status == 'ATENDIDO' || novaSenha.status == 'CANCELADO') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('senha_activa_${novaSenha.servico}');
          _timer?.cancel();
        }
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _enviarNotificacao(String titulo, String corpo) async {
    const android = AndroidNotificationDetails(
      'bci_detalhes', 'BCI Alertas',
      importance: Importance.max, priority: Priority.high, playSound: true,
    );
    await notificacoes.show(
      id: 1,
      title: titulo,
      body: corpo,
      notificationDetails: const NotificationDetails(android: android),
    );
  }

  Future<void> _cancelarSenha() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Cancelar Senha', style: TextStyle(color: Colors.white)),
        content: const Text('Tens a certeza que queres cancelar esta senha?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim, cancelar')),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _carregando = true);
      try {
        await _service.cancelarSenha(_senhaActual.id);
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('senha_activa_${_senhaActual.servico}');
        if (mounted) Navigator.pop(context);
      } catch (e) {
        setState(() => _carregando = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao cancelar.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = _corEstado(_senhaActual.status);
    final ativa = _senhaActual.status == 'ESPERANDO' || _senhaActual.status == 'EM_ATENDIMENTO';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Detalhes da Senha', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: _carregando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh),
            onPressed: () => _actualizarDados(),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Card da Senha
            Container(
              width: double.infinity, padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), border: Border.all(color: const Color(0xFF3A3A3A))),
              child: Column(
                children: [
                  const Text('SENHA', style: TextStyle(color: Color(0xFF888888), fontSize: 11, letterSpacing: 3)),
                  Text(_senhaActual.codigo, style: const TextStyle(color: Color(0xFFE8001D), fontSize: 80, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: cor.withOpacity(0.1), border: Border.all(color: cor.withOpacity(0.4))),
                    child: Text(_textoEstado(_senhaActual.status), style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Infos
            Container(
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), border: Border.all(color: const Color(0xFF3A3A3A))),
              child: Column(
                children: [
                  _buildLinha('Cliente', widget.nomeCliente, Icons.person),
                  _buildLinha('Serviço', _senhaActual.servico, Icons.category),
                  _buildLinha('Posição', _senhaActual.status == 'ESPERANDO' ? '${_senhaActual.posicaoFila}º lugar' : '—', Icons.people),
                  if (_senhaActual.balcao != null) _buildLinha('Balcão', _senhaActual.balcao!, Icons.desk),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (ativa)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _carregando ? null : _cancelarSenha,
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE8001D)), foregroundColor: const Color(0xFFE8001D), padding: const EdgeInsets.all(16)),
                  child: const Text('CANCELAR SENHA'),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text('VOLTAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinha(String label, String valor, IconData icone) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [Icon(icone, size: 18, color: const Color(0xFFE8001D)), const SizedBox(width: 12), Text(label, style: const TextStyle(color: Color(0xFF888888))), const Spacer(), Text(valor, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
    );
  }

  Color _corEstado(String status) => status == 'EM_ATENDIMENTO' ? Colors.green : (status == 'ESPERANDO' ? Colors.orange : Colors.grey);
  String _textoEstado(String status) => status == 'EM_ATENDIMENTO' ? 'Em Atendimento' : (status == 'ESPERANDO' ? 'Em Espera' : status);
}
