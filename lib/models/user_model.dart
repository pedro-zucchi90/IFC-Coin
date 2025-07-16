// Modelo de dados do usuário utilizado no app Flutter
class User {
  final String? id; // ID do usuário (MongoDB)
  final String nome; // Nome completo
  final String email; // Email
  final String matricula; // Matrícula institucional
  final String role; // Papel: aluno, professor ou admin
  final String? curso; // Curso (apenas para alunos)
  final List<String> turmas; // Lista de turmas
  final int saldo; // Saldo de coins
  final String? fotoPerfil; // URL ou caminho da foto de perfil
  final String? statusAprovacao; // Status de aprovação (professor)
  final DateTime? createdAt; // Data de criação
  final DateTime? updatedAt; // Data de atualização

  User({
    this.id,
    required this.nome,
    required this.email,
    required this.matricula,
    required this.role,
    this.curso,
    required this.turmas,
    required this.saldo,
    this.fotoPerfil,
    this.statusAprovacao,
    this.createdAt,
    this.updatedAt,
  });

  // Cria um User a partir de um JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      nome: json['nome'],
      email: json['email'],
      matricula: json['matricula'],
      role: json['role'],
      curso: json['curso'],
      turmas: List<String>.from(json['turmas'] ?? []),
      saldo: json['saldo'] ?? 0,
      fotoPerfil: json['fotoPerfil'],
      statusAprovacao: json['statusAprovacao'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  // Converte o User para JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nome': nome,
      'email': email,
      'matricula': matricula,
      'role': role,
      'curso': curso,
      'turmas': turmas,
      'saldo': saldo,
      'fotoPerfil': fotoPerfil,
      'statusAprovacao': statusAprovacao,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Cria uma cópia do usuário com campos modificados
  User copyWith({
    String? id,
    String? nome,
    String? email,
    String? matricula,
    String? role,
    String? curso,
    List<String>? turmas,
    int? saldo,
    String? fotoPerfil,
    String? statusAprovacao,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      matricula: matricula ?? this.matricula,
      role: role ?? this.role,
      curso: curso ?? this.curso,
      turmas: turmas ?? this.turmas,
      saldo: saldo ?? this.saldo,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      statusAprovacao: statusAprovacao ?? this.statusAprovacao,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Classe auxiliar para requisição de login
class LoginRequest {
  final String matricula;
  final String senha;

  LoginRequest({
    required this.matricula,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {
      'matricula': matricula,
      'senha': senha,
    };
  }
}

// Classe auxiliar para resposta de login
class LoginResponse {
  final String token;
  final User user;
  final bool showApprovalNotification;

  LoginResponse({
    required this.token,
    required this.user,
    this.showApprovalNotification = false,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
      showApprovalNotification: json['showApprovalNotification'] ?? false,
    );
  }
} 