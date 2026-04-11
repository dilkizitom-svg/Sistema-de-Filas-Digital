class Senha {
  final int id;
  final int numeroSenha;
  final String servico;
  final String status;
  final String horarioCriacao;
  final String? balcao;
  final int? posicaoFila;
  final int? tempoEstimadoEspera;

  Senha({
    required this.id,
    required this.numeroSenha,
    required this.servico,
    required this.status,
    required this.horarioCriacao,
    this.balcao,
    this.posicaoFila,
    this.tempoEstimadoEspera,
  });

  // Código formatado — ex: C001, A002
  String get codigo {
    final prefixo = servico.toUpperCase() == 'CAIXA' ? 'C' : 'A';
    return '$prefixo${numeroSenha.toString().padLeft(3, '0')}';
  }

  factory Senha.fromJson(Map<String, dynamic> json) {
    return Senha(
      id: json['id'],
      numeroSenha: json['numeroSenha'],
      servico: json['servico'],
      status: json['status'],
      horarioCriacao: json['horarioCriacao'],
      balcao: json['balcao'],
      posicaoFila: json['posicaoFila'],
      tempoEstimadoEspera: json['tempoEstimadoEspera'],
    );
  }
}