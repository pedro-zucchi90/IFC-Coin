class User {
  final String? id;
  final String nome;
  final String email;
  final String matricula;
  final String role;
  final String? curso;
  final List<String> turmas;
  final int saldo;
  final String? fotoPerfil;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

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
      'email': email,
      'matricula': matricula,
      'role': role,
      'curso': curso,
      'turmas': turmas,
      'saldo': saldo,
      'fotoPerfil': fotoPerfil,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

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

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
} 