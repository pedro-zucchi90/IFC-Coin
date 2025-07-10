class Achievement {
  final String? id;
  final String nome;
  final String descricao;
  final String tipo;
  final String? categoria;
  final String? icone;
  final String? requisitos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Achievement({
    this.id,
    required this.nome,
    required this.descricao,
    required this.tipo,
    this.categoria,
    this.icone,
    this.requisitos,
    this.createdAt,
    this.updatedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['_id'],
      nome: json['nome'],
      descricao: json['descricao'],
      tipo: json['tipo'],
      categoria: json['categoria'],
      icone: json['icone'],
      requisitos: json['requisitos'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo,
      'categoria': categoria,
      'icone': icone,
      'requisitos': requisitos,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Achievement copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? tipo,
    String? categoria,
    String? icone,
    String? requisitos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      icone: icone ?? this.icone,
      requisitos: requisitos ?? this.requisitos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 