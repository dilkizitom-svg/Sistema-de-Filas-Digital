import 'package:dio/dio.dart';
import '../models/senha.dart';
import 'dart:convert';

class SenhaService {
  static const String baseUrl = 'https://nonechoic-milena-habitually.ngrok-free.dev/api';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Basic ${base64Encode(utf8.encode('atendente:1234'))}',
      },
    ),
  );

  Future<Senha> gerarSenha(String servico) async {
    final response = await _dio.post('/senha', queryParameters: {'servico': servico});
    return Senha.fromJson(response.data);
  }

  Future<List<Senha>> listarFilaPorServico(String servico) async {
    final response = await _dio.get('/fila', queryParameters: {'servico': servico});
    return (response.data as List).map((json) => Senha.fromJson(json)).toList();
  }

  Future<List<Senha>> listarFila() async {
    final response = await _dio.get('/fila');
    return (response.data as List).map((json) => Senha.fromJson(json)).toList();
  }

  Future<Senha> consultarPosicao(int id) async {
    final response = await _dio.get('/senha/$id/posicao');
    return Senha.fromJson(response.data);
  }

  Future<Senha> chamarProxima(String balcao, String servico) async {
    final response = await _dio.post('/fila/chamar', queryParameters: {'balcao': balcao, 'servico': servico});
    return Senha.fromJson(response.data);
  }

  Future<Senha> marcarAtendido(int id) async {
    final response = await _dio.put('/senha/$id/atendido');
    return Senha.fromJson(response.data);
  }

  Future<Senha> cancelarSenha(int id) async {
    final response = await _dio.put('/senha/$id/cancelar');
    return Senha.fromJson(response.data);
  }
}
