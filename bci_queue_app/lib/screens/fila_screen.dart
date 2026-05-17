import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/senha.dart';
import '../services/senha_service.dart';

class FilaScreen extends StatefulWidget {
  final int? senhaId;
  final String? servico;

  const FilaScreen({super.key, this.senhaId, this.servico});

  @override
  State<FilaScreen> createState() => _FilaScreenState();
}

class _FilaScreenState extends State<FilaScreen>
    with SingleTickerProviderStateMixin {
  final SenhaService _service = SenhaService();
  List<Senha> _filaCaixa = [];
  List<Senha> _filaAtendimento = [];
  Senha? _minhaSenha;
  bool _carregando = true;
  
  // Flags separadas para notificações
  bool _notificacaoVezPertoEnviada = false;
  bool _notificacaoChamadaEnviada = false;
  
  bool _permissaoPedida = false;
  Timer? _timer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.servico == 'ATENDIMENTO' ? 1 : 0,
    );
    _carregarDados();
    _timer = Timer.periodic(
      const Duration(seconds: 5), // Reduzido para 5s para ser mais "tempo real"
      (_) => _carregarDados(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pedirPermissaoNotificacoes() async {
    if (_permissaoPedida) return;
    try {
      final androidPlugin = notificacoes
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
      setState(() => _permissaoPedida = true);
    } catch (_) {}
  }

  Future<void> _carregarDados() async {
    await _pedirPermissaoNotificacoes();

    try {
      final caixa = await _service.listarFilaPorServico('CAIXA');
      final atendimento = await _service.listarFilaPorServico('ATENDIMENTO');

      Senha? minhaSenha;
      if (widget.senhaId != null) {
        try {
          minhaSenha = await _service.consultarPosicao(widget.senhaId!);

          if (minhaSenha.status == 'ATENDIDO' || minhaSenha.status == 'CANCELADO') {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('senha_activa_${minhaSenha.servico}');

            if (_minhaSenha != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    minhaSenha.status == 'ATENDIDO'
                        ? 'O teu atendimento foi concluído! ✅'
                        : 'A tua senha foi cancelada.',
                  ),
                  backgroundColor: minhaSenha.status == 'ATENDIDO'
                      ? const Color(0xFF00C853)
                      : const Color(0xFFE8001D),
                ),
              );
            }
            minhaSenha = null;
          }
        } catch (_) {
          minhaSenha = null;
        }
      }

      // ── Verificar notificações melhorada ────────────────
      if (minhaSenha != null) {
        final posicao = minhaSenha.posicaoFila ?? 99;
        final status = minhaSenha.status;

        // Notificação: Vez está a chegar (Posição 1 ou 2)
        if (posicao <= 2 && status == 'ESPERANDO' && !_notificacaoVezPertoEnviada) {
          await _enviarNotificacao(
            'A tua vez está a chegar! ⏳',
            'Faltam aproximadamente ${posicao * 5} minutos para a senha ${minhaSenha.codigo}.',
          );
          _notificacaoVezPertoEnviada = true;
        }

        // Notificação: Chamada ao balcão
        if (status == 'EM_ATENDIMENTO' && !_notificacaoChamadaEnviada) {
          await _enviarNotificacao(
            '🔔 É a tua vez!',
            'Senha ${minhaSenha.codigo} — dirija-se ao balcão imediatamente.',
          );
          _notificacaoChamadaEnviada = true;
        }
      }

      setState(() {
        _filaCaixa = caixa;
        _filaAtendimento = atendimento;
        _minhaSenha = minhaSenha;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  Future<void> _enviarNotificacao(String titulo, String corpo) async {
    try {
      const android = AndroidNotificationDetails(
        'bci_smartfila',
        'BCI SmartFila',
        channelDescription: 'Notificações de fila',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
      const detalhes = NotificationDetails(android: android);
      await notificacoes.show(id: 0, title: titulo, body: corpo, notificationDetails: detalhes);
    } catch (_) {}
  }

  Future<void> _cancelarSenha() async {
    if (_minhaSenha == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Cancelar Senha', style: TextStyle(color: Colors.white)),
        content: const Text('Tens a certeza que queres cancelar a tua senha?', style: TextStyle(color: Color(0xFF888888))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não', style: TextStyle(color: Color(0xFF888888)))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim, cancelar')),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _service.cancelarSenha(_minhaSenha!.id);
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('senha_activa_${_minhaSenha!.servico}');
        _carregarDados(); // Recarregar para limpar da UI
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao cancelar senha.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: const Color(0xFFE8001D),
              child: const Text('BCI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2)),
            ),
            const SizedBox(width: 10),
            const Text('Fila de Espera', style: TextStyle(fontSize: 16, color: Color(0xFF888888))),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF888888)), onPressed: _carregarDados),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE8001D),
          tabs: [
            Tab(text: 'Caixa (${_filaCaixa.length})', icon: const Icon(Icons.payments, size: 16)),
            Tab(text: 'Atendimento (${_filaAtendimento.length})', icon: const Icon(Icons.support_agent, size: 16)),
          ],
        ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8001D)))
          : Column(
              children: [
                if (_minhaSenha != null) _buildMinhaSenhaCard(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildListaFila(_filaCaixa),
                      _buildListaFila(_filaAtendimento),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildListaFila(List<Senha> fila) {
    if (fila.isEmpty) {
      return const Center(child: Text('A fila está vazia.', style: TextStyle(color: Color(0xFF888888))));
    }

    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: fila.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _buildSenhaCard(fila[i], i + 1),
      ),
    );
  }

  Widget _buildMinhaSenhaCard() {
    final senha = _minhaSenha!;
    final emAtendimento = senha.status == 'EM_ATENDIMENTO';
    final faltaPouco = (senha.posicaoFila ?? 99) <= 2 && !emAtendimento;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: emAtendimento ? const Color(0xFFE8001D) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: faltaPouco ? const Color(0xFFFF9100) : const Color(0xFF3A3A3A)),
      ),
      child: Column(
        children: [
          Text(emAtendimento ? '🔔 É A TUA VEZ!' : 'A TUA SENHA', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color(0xFF888888))),
          const SizedBox(height: 8),
          Text(senha.codigo, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
          if (!emAtendimento) ...[
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildChip('${senha.posicaoFila}º na fila', Icons.people), _buildChip('~${senha.tempoEstimadoEspera} min', Icons.timer)]),
            const SizedBox(height: 8),
            TextButton(onPressed: _cancelarSenha, child: const Text('Cancelar senha', style: TextStyle(color: Color(0xFFE8001D)))),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String texto, IconData icone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(4)),
      child: Row(children: [Icon(icone, size: 14, color: const Color(0xFFE8001D)), const SizedBox(width: 6), Text(texto, style: const TextStyle(fontSize: 12, color: Colors.white))]),
    );
  }

  Widget _buildSenhaCard(Senha senha, int posicao) {
    final eMinha = _minhaSenha?.id == senha.id;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), border: Border.all(color: eMinha ? const Color(0xFFE8001D) : const Color(0xFF3A3A3A))),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF2C2C2C)), child: Center(child: Text(senha.codigo, style: const TextStyle(color: Colors.white)))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(eMinha ? 'A tua senha' : 'Senha ${senha.codigo}', style: const TextStyle(color: Colors.white)), Text('~${senha.tempoEstimadoEspera} min', style: const TextStyle(color: Color(0xFF888888)))])),
          Text('$posicao', style: const TextStyle(fontSize: 22, color: Color(0xFF3A3A3A))),
        ],
      ),
    );
  }
}
