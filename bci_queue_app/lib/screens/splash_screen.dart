import 'package:flutter/material.dart';
import 'boas_vindas_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'fila_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navegar após 3 segundos
    Future.delayed(const Duration(seconds: 3), _navegar);
  }

  Future<void> _navegar() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString('cliente_nome');

    if (!mounted) return;

    if (nome != null && nome.isNotEmpty) {
      // Verificar se tem senha activa
      final senhaCaixaId = prefs.getInt('senha_activa_CAIXA');
      final senhaAtendId = prefs.getInt('senha_activa_ATENDIMENTO');

      if (senhaCaixaId != null || senhaAtendId != null) {
        final senhaId = senhaCaixaId ?? senhaAtendId;
        final servico = senhaCaixaId != null ? 'CAIXA' : 'ATENDIMENTO';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FilaScreen(senhaId: senhaId, servico: servico),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BoasVindasScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo ─────────────────────────────────
                Image.asset(
                  'assets/images/logo.png',
                  width: 220,
                ),
                const SizedBox(height: 32),

                // ── Texto de boas-vindas ──────────────────
                const Text(
                  'Bem-vindo ao',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Smart Filas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gestão inteligente de filas bancárias',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 48),

                // ── Loading ───────────────────────────────
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Color(0xFFE8001D),
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}