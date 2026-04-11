import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'fila_screen.dart';
import '../services/senha_service.dart';


class IdentificacaoScreen extends StatefulWidget {
  const IdentificacaoScreen({super.key});

  @override
  State<IdentificacaoScreen> createState() => _IdentificacaoScreenState();
}

class _IdentificacaoScreenState extends State<IdentificacaoScreen> {
  final _nomeCtrl = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

 Future<void> _verificarSessao() async {
  final prefs = await SharedPreferences.getInstance();
  final nome = prefs.getString('cliente_nome');

  if (nome == null || nome.isEmpty) return; // Sem sessão — fica no login

  // Verificar se tem senha activa válida no servidor
  final senhaCaixaId = prefs.getInt('senha_activa_CAIXA');
  final senhaAtendId = prefs.getInt('senha_activa_ATENDIMENTO');

  if (senhaCaixaId != null || senhaAtendId != null) {
    final senhaId = senhaCaixaId ?? senhaAtendId;
    final servico = senhaCaixaId != null ? 'CAIXA' : 'ATENDIMENTO';

    // Verificar no servidor se a senha ainda está activa
    try {
      final service = SenhaService();
      final senha = await service.consultarPosicao(senhaId!);

      if (senha.status == 'ESPERANDO' || senha.status == 'EM_ATENDIMENTO') {
        // Senha válida — ir para a fila
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => FilaScreen(senhaId: senhaId, servico: servico),
            ),
          );
        }
        return;
      } else {
        // Senha já concluída — limpar e ir para home
        await prefs.remove('senha_activa_CAIXA');
        await prefs.remove('senha_activa_ATENDIMENTO');
      }
    } catch (e) {
      // Senha não existe ou servidor inacessível — limpar e ir para home
      await prefs.remove('senha_activa_CAIXA');
      await prefs.remove('senha_activa_ATENDIMENTO');
    }
  }

  // Tem sessão mas sem senha activa — ir para home
  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}

  Future<void> _entrar() async {
    final nome = _nomeCtrl.text.trim();
    

    if (nome.isEmpty) {
      _mostrarErro('Introduza o seu nome.');
      return;
    }
    

    setState(() => _carregando = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cliente_nome', nome);
    //await prefs.setString('cliente_tel', tel);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFE8001D),
      ),
    );
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
   
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF888888)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Cabeçalho ─────────────────────────────────
              Container(
                width: 40, height: 4,
                color: const Color(0xFFE8001D),
              ),
              const SizedBox(height: 20),
              const Text(
                'Identificação',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Precisamos do seu nome e contacto para associar a senha.',
                style: TextStyle(color: Color(0xFF888888), fontSize: 14, height: 1.6),
              ),

              const SizedBox(height: 48),

              // ── Campo Nome ────────────────────────────────
              _buildCampo('NOME COMPLETO', 'Ex: Carlos Machava', _nomeCtrl, false),
              const SizedBox(height: 20),

              

              const Spacer(),

              // ── Botão Entrar ──────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _entrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8001D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    disabledBackgroundColor: const Color(0xFF3A3A3A),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'ENTRAR',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampo(String label, String hint, TextEditingController ctrl, bool obscure,
      {TextInputType teclado = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: teclado,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF3A3A3A)),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: Color(0xFFE8001D)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}