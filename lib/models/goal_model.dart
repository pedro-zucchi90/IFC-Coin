class Goal {
  final String? id;
  final String titulo;
  final String descricao;
  final String tipo;
  final int requisito;
  final int recompensa;
  final List<String> usuariosConcluidos;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? usuarioConcluiu; // Campo adicional para verificar se o usuário atual concluiu
  final bool? temSolicitacaoPendente; // Campo adicional para verificar se tem solicitação pendente
  
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
    required this.requisito,
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
      requisito: json['requisito'],
      recompensa: json['recompensa'],
      usuariosConcluidos: List<String>.from(json['usuariosConcluidos'] ?? []),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      usuarioConcluiu: json['usuarioConcluiu'],
      temSolicitacaoPendente: json['temSolicitacaoPendente'],
      ativo: json['ativo'] ?? true,
      requerAprovacao: json['requerAprovacao'] ?? false,
      maxConclusoes: json['maxConclusoes'],
      periodoValidade: json['periodoValidade'],
      dataInicio: json['dataInicio'] != null 
          ? DateTime.parse(json['dataInicio']) 
          : null,
      dataFim: json['dataFim'] != null 
          ? DateTime.parse(json['dataFim']) 
          : null,
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
      'requisito': requisito,
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
    int? requisito,
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
      requisito: requisito ?? this.requisito,
      recompensa: recompensa ?? this.recompensa,
      usuariosConcluidos: usuariosConcluidos ?? this.usuariosConcluidos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usuarioConcluiu: usuarioConcluiu ?? this.usuarioConcluiu,
    );
  }
} 