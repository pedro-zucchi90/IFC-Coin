class Goal {
  final String? id;
  final String titulo;
  final String descricao;
  final String tipo;
  final int recompensa;
  final List<String> usuariosConcluidos;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? usuarioConcluiu;
  final bool? temSolicitacaoPendente;

  // Controles de segurança
  final bool ativo;
  final bool requerAprovacao;
  final int? maxConclusoes;
  final int? periodoValidade;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  // Evidências necessárias
  final bool evidenciaObrigatoria;
  final String tipoEvidencia;
  final String? descricaoEvidencia;

  Goal({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.recompensa,
    required this.usuariosConcluidos,
    this.createdAt,
    this.updatedAt,
    this.usuarioConcluiu,
    this.temSolicitacaoPendente,
    this.ativo = true,
    this.requerAprovacao = false,
    this.maxConclusoes,
    this.periodoValidade,
    this.dataInicio,
    this.dataFim,
    this.evidenciaObrigatoria = false,
    this.tipoEvidencia = 'texto',
    this.descricaoEvidencia,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['_id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      tipo: json['tipo'],
      recompensa: json['recompensa'],
      usuariosConcluidos: List<String>.from(json['usuariosConcluidos'] ?? []),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      usuarioConcluiu: json['usuarioConcluiu'],
      temSolicitacaoPendente: json['temSolicitacaoPendente'],
      ativo: json['ativo'] ?? true,
      requerAprovacao: json['requerAprovacao'] ?? false,
      maxConclusoes: json['maxConclusoes'],
      periodoValidade: json['periodoValidade'],
      dataInicio: json['dataInicio'] != null ? DateTime.parse(json['dataInicio']) : null,
      dataFim: json['dataFim'] != null ? DateTime.parse(json['dataFim']) : null,
      evidenciaObrigatoria: json['evidenciaObrigatoria'] ?? false,
      tipoEvidencia: json['tipoEvidencia'] ?? 'texto',
      descricaoEvidencia: json['descricaoEvidencia'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'titulo': titulo,
      'descricao': descricao,
      'tipo': tipo,
      'recompensa': recompensa,
      'usuariosConcluidos': usuariosConcluidos,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'usuarioConcluiu': usuarioConcluiu,
    };
  }

  Goal copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? tipo,
    int? recompensa,
    List<String>? usuariosConcluidos,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? usuarioConcluiu,
  }) {
    return Goal(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      recompensa: recompensa ?? this.recompensa,
      usuariosConcluidos: usuariosConcluidos ?? this.usuariosConcluidos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usuarioConcluiu: usuarioConcluiu ?? this.usuarioConcluiu,
    );
  }
}

class GoalRequest {
  final String id;
  final Goal? goal; // <- nullable agora
  final Map<String, dynamic> aluno;
  final String status;
  final String? comentario;
  final String? evidenciaTexto;
  final String? evidenciaArquivo;
  final String? resposta;
  final String? analisadoPor;
  final DateTime? dataAnalise;
  final DateTime createdAt;

  GoalRequest({
    required this.id,
    required this.goal,
    required this.aluno,
    required this.status,
    this.comentario,
    this.evidenciaTexto,
    this.evidenciaArquivo,
    this.resposta,
    this.analisadoPor,
    this.dataAnalise,
    required this.createdAt,
  });

  factory GoalRequest.fromJson(Map<String, dynamic> json) {
    return GoalRequest(
      id: json['_id'],
      goal: json['goal'] != null ? Goal.fromJson(json['goal']) : null,
      aluno: json['aluno'],
      status: json['status'],
      comentario: json['comentario'],
      evidenciaTexto: json['evidenciaTexto'],
      evidenciaArquivo: json['evidenciaArquivo'],
      resposta: json['resposta'],
      analisadoPor: json['analisadoPor']?.toString(),
      dataAnalise: json['dataAnalise'] != null ? DateTime.parse(json['dataAnalise']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
