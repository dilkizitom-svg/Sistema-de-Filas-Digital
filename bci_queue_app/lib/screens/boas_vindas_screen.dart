import 'package:flutter/material.dart';
import 'identificacao_screen.dart';

class BoasVindasScreen extends StatelessWidget {
  const BoasVindasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Logo ─────────────────────────────────────
             // ── Logo ─────────────────────────────────────
Image.asset(
  'assets/images/logo.png',
  width: 180,
),
const SizedBox(height: 32),

              const SizedBox(height: 40),

              // ── Slogan ────────────────────────────────────
              const Text(
                'É do povo, é daqui.',
                style: TextStyle(
                  color: Color(0xFFE8001D),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // ── Descrição ─────────────────────────────────
              const Text(
                'Retire a sua senha, acompanhe a fila em tempo real e seja notificado quando for a sua vez — tudo pelo telemóvel.',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 14,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // ── Funcionalidades ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeature(Icons.confirmation_number_outlined, 'Senha\nDigital'),
                  _buildFeature(Icons.people_outline, 'Fila em\nTempo Real'),
                  _buildFeature(Icons.notifications_outlined, 'Notifi-\ncações'),
                ],
              ),

              const Spacer(flex: 2),

              // ── Botão Começar ─────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const IdentificacaoScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8001D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text(
                    'COMEÇAR',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
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

  Widget _buildFeature(IconData icone, String texto) {
    return Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            border: Border.all(color: const Color(0xFF3A3A3A)),
          ),
          child: Icon(icone, color: const Color(0xFFE8001D), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          texto,
          style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}