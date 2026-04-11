import 'package:flutter/material.dart';
import '../models/senha.dart';
import '../services/senha_service.dart';
import 'fila_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'senha_detalhes_screen.dart';
import 'boas_vindas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SenhaService _service = SenhaService();
  bool _carregando = false;
  Senha? _ultimaSenha;
  String _nomeCliente = '';

  final List<Map<String, dynamic>> _servicos = [
    {'nome': 'CAIXA',       'icone': Icons.payments,      'label': 'Caixa / Depósito'},
    {'nome': 'ATENDIMENTO', 'icone': Icons.support_agent, 'label': 'Atendimento'},
  ];

  @override
void initState() {
  super.initState();
  _carregarNome();
  _verificarSenhasActivas();
}

  Future<void> _carregarNome() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _nomeCliente = prefs.getString('cliente_nome') ?? '');
  }

 

Future<void> _verificarSenhasActivas() async {
  final prefs = await SharedPreferences.getInstance();
  
  for (final servico in ['CAIXA', 'ATENDIMENTO']) {
    final senhaId = prefs.getInt('senha_activa_$servico');
    if (senhaId != null) {
      try {
        final senha = await _service.consultarPosicao(senhaId);
        if (senha.status == 'ATENDIDO' || senha.status == 'CANCELADO') {
          await prefs.remove('senha_activa_$servico');
        } else {
          // Senha ainda activa — mostrar na AppBar
          setState(() => _ultimaSenha = senha);
        }
      } catch (_) {
        await prefs.remove('senha_activa_$servico');
      }
    }
  }
}

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text('Terminar Sessão', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tens a certeza que queres sair?',
          style: TextStyle(color: Color(0xFF888888)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF888888))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BoasVindasScreen()),
        (route) => false,
      );
    }
  }

  void _mostrarErroSenhaActiva(Senha senha, String label) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text(
          'Já tens uma senha activa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9100), size: 48),
            const SizedBox(height: 16),
            Text(
              'Já tens a senha ${senha.codigo} activa para $label.',
              style: const TextStyle(color: Color(0xFF888888), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Posição: ${senha.posicaoFila}º · ~${senha.tempoEstimadoEspera} min',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Color(0xFF888888))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FilaScreen(senhaId: senha.id, servico: senha.servico),
                ),
              );
            },
            child: const Text('Ver Fila'),
          ),
        ],
      ),
    );
  }

  Future<void> _gerarSenha(String servico, String label) async {
    final prefs = await SharedPreferences.getInstance();
    final senhaIdGuardada = prefs.getInt('senha_activa_$servico');

    if (senhaIdGuardada != null) {
      try {
        final senhaActiva = await _service.consultarPosicao(senhaIdGuardada);
        if (senhaActiva.status == 'ESPERANDO' || senhaActiva.status == 'EM_ATENDIMENTO') {
          _mostrarErroSenhaActiva(senhaActiva, label);
          return;
        } else {
          await prefs.remove('senha_activa_$servico');
        }
      } catch (e) {
        await prefs.remove('senha_activa_$servico');
      }
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text('Confirmar Senha', style: TextStyle(color: Colors.white)),
        content: Text(
          'Deseja tirar uma senha para:\n\n$label?',
          style: const TextStyle(color: Color(0xFF888888)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF888888))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _carregando = true);
    try {
      final senha = await _service.gerarSenha(servico);
      await prefs.setInt('senha_activa_$servico', senha.id);
      setState(() => _ultimaSenha = senha);
      _mostrarSenhaGerada(senha);
    } catch (e) {
      _mostrarErro('Erro ao gerar senha. Verifica a ligação.');
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _mostrarSenhaGerada(Senha senha) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text(
          'Senha Gerada!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              senha.codigo,
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE8001D),
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF3A3A3A)),
              ),
              child: Text(
                senha.servico,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChip('${senha.posicaoFila}º na fila', Icons.people),
                _buildChip('~${senha.tempoEstimadoEspera} min', Icons.timer),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SenhaDetalhesScreen(
                    senha: senha,
                    nomeCliente: _nomeCliente,
                  ),
                ),
              );
            },
            child: const Text('Ver Detalhes', style: TextStyle(color: Color(0xFFE8001D))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FilaScreen(senhaId: senha.id, servico: senha.servico),
                ),
              );
            },
            child: const Text('Acompanhar Fila'),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String texto, IconData icone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: const Color(0xFFE8001D)),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: const Color(0xFFE8001D)),
    );
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
              child: const Text(
                'BCI',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2),
              ),
            ),
            const SizedBox(width: 10),
            const Text('SmartFila', style: TextStyle(fontSize: 16, color: Color(0xFF888888))),
          ],
        ),
        actions: [
          if (_ultimaSenha != null)
            IconButton(
              icon: const Icon(Icons.confirmation_number_outlined, color: Color(0xFFE8001D)),
              tooltip: 'Ver Senha',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SenhaDetalhesScreen(
                    senha: _ultimaSenha!,
                    nomeCliente: _nomeCliente,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.list, color: Color(0xFF888888)),
            tooltip: 'Ver Fila',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FilaScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF888888)),
            tooltip: 'Terminar Sessão',
            onPressed: _logout,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF3A3A3A)),
        ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8001D)))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Olá, $_nomeCliente!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Selecciona o serviço pretendido:',
                    style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _servicos.length,
                      itemBuilder: (context, index) {
                        final s = _servicos[index];
                        return GestureDetector(
                          onTap: () => _gerarSenha(s['nome'], s['label']),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF3A3A3A)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(s['icone'], size: 40, color: const Color(0xFFE8001D)),
                                const SizedBox(height: 14),
                                Text(
                                  s['label'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}