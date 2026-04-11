import 'dart:async';
import 'package:flutter/material.dart';
import '../models/senha.dart';
import '../services/senha_service.dart';

class OperadorScreen extends StatefulWidget {
  const OperadorScreen({super.key});

  @override
  State<OperadorScreen> createState() => _OperadorScreenState();
}

class _OperadorScreenState extends State<OperadorScreen> {
  final SenhaService _service = SenhaService();
  String _servicoSeleccionado = 'CAIXA';
  String _balcao = 'Balcao 1';
  Senha? _senhaActual;
  List<Senha> _fila = [];
  bool _carregando = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregarFila();
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _carregarFila(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregarFila() async {
    try {
      final fila = await _service.listarFilaPorServico(_servicoSeleccionado);
      setState(() => _fila = fila);
    } catch (e) {}
  }

  Future<void> _chamarProxima() async {
    if (_fila.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A fila de $_servicoSeleccionado está vazia.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _carregando = true);
    try {
      final senha = await _service.chamarProxima(_balcao, _servicoSeleccionado);
      setState(() => _senhaActual = senha);
      await _carregarFila();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao chamar senha.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _marcarAtendido() async {
    if (_senhaActual == null) return;

    setState(() => _carregando = true);
    try {
      await _service.marcarAtendido(_senhaActual!.id);
      setState(() => _senhaActual = null);
      await _carregarFila();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atendimento concluído!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao concluir atendimento.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8001D),
        title: const Text(
          'Painel do Operador',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Configuração ──────────────────────────────────────
            _buildCard(
              titulo: 'Configuração',
              child: Column(
                children: [
                  // Selecção do serviço
                  Row(
                    children: [
                      const Text(
                        'Serviço:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'CAIXA',
                              label: Text('Caixa'),
                              icon: Icon(Icons.payments, size: 16),
                            ),
                            ButtonSegment(
                              value: 'ATENDIMENTO',
                              label: Text('Atendimento'),
                              icon: Icon(Icons.support_agent, size: 16),
                            ),
                          ],
                          selected: {_servicoSeleccionado},
                          onSelectionChanged: (value) {
                            setState(() {
                              _servicoSeleccionado = value.first;
                              _senhaActual = null;
                            });
                            _carregarFila();
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFFE8001D);
                              }
                              return Colors.white;
                            }),
                            foregroundColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white;
                              }
                              return Colors.black87;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Balcão
                  Row(
                    children: [
                      const Text(
                        'Balcão:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _balcao,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items:
                              ['Balcao 1', 'Balcao 2', 'Balcao 3', 'Balcao 4']
                                  .map(
                                    (b) => DropdownMenuItem(
                                      value: b,
                                      child: Text(b),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => _balcao = v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Senha actual em atendimento ───────────────────────
            _buildCard(
              titulo: 'Em Atendimento',
              child: _senhaActual == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Nenhuma senha em atendimento.\nClica em "Chamar Próxima" para começar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8001D),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    '${_senhaActual!.numeroSenha}',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _senhaActual!.servico,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _senhaActual!.balcao ?? '',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _carregando ? null : _marcarAtendido,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Concluir Atendimento'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            // ── Fila actual ───────────────────────────────────────
            _buildCard(
              titulo:
                  'Fila de $_servicoSeleccionado (${_fila.length} em espera)',
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _carregando ? null : _chamarProxima,
                      icon: _carregando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.campaign),
                      label: const Text('Chamar Próxima Senha'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8001D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_fila.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Fila vazia.',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _fila.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final s = _fila[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: i == 0
                                ? const Color(0xFFE8001D)
                                : Colors.grey.shade200,
                            child: Text(
                              '${s.numeroSenha}',
                              style: TextStyle(
                                color: i == 0 ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text('Senha ${s.numeroSenha}'),
                          subtitle: Text(
                            '~${s.tempoEstimadoEspera} min de espera',
                          ),
                          trailing: i == 0
                              ? const Chip(
                                  label: Text(
                                    'Próxima',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: Color(0xFFFFE0E0),
                                )
                              : Text(
                                  '${i + 1}º',
                                  style: TextStyle(color: Colors.grey.shade400),
                                ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String titulo, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}
