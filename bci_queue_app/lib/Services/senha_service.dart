import 'package:dio/dio.dart';
import '../models/senha.dart';

class SenhaService {
  static const String baseUrl  = 'https://nonechoic-milena-habitually.ngrok-free.dev/api';


  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  // ── Gerar nova senha ──────────────────────────────────
  Future<Senha> gerarSenha(String servico) async {
    final response = await _dio.post(
      '/senha',
      queryParameters: {'servico': servico},
    );
    return Senha.fromJson(response.data);
  }

  // ── Listar fila por serviço ───────────────────────────
  Future<List<Senha>> listarFilaPorServico(String servico) async {
    final response = await _dio.get(
      '/fila',
      queryParameters: {'servico': servico},
    );
    return (response.data as List).map((json) => Senha.fromJson(json)).toList();
  }

  // ── Listar todas as filas ─────────────────────────────
  Future<List<Senha>> listarFila() async {
    final response = await _dio.get('/fila');
    return (response.data as List).map((json) => Senha.fromJson(json)).toList();
  }

  // ── Consultar posição ─────────────────────────────────
  Future<Senha> consultarPosicao(int id) async {
    final response = await _dio.get('/senha/$id/posicao');
    return Senha.fromJson(response.data);
  }

  // ── Chamar próxima senha ──────────────────────────────
  Future<Senha> chamarProxima(String balcao, String servico) async {
    final response = await _dio.post(
      '/fila/chamar',
      queryParameters: {'balcao': balcao, 'servico': servico},
    );
    return Senha.fromJson(response.data);
  }

  // ── Marcar como atendido ──────────────────────────────
  Future<Senha> marcarAtendido(int id) async {
    final response = await _dio.put('/senha/$id/atendido');
    return Senha.fromJson(response.data);
  }

  // ── Cancelar senha ────────────────────────────────────
  Future<Senha> cancelarSenha(int id) async {
    final response = await _dio.put('/senha/$id/cancelar');
    return Senha.fromJson(response.data);
  }
}
