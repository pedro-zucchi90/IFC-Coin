// Modelo de dados para transações de IFC Coin
import 'user_model.dart';

class Transaction {
  final String? id;
  final String tipo; // 'recebido' ou 'enviado'
  final User? origem;
  final User? destino;
  final int quantidade;
  final String descricao;
  final String hash;
  final String? status; // 'pendente', 'aprovada', 'recusada' (para transferências professor-aluno)
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    this.id,
    required this.tipo,
    this.origem,
    this.destino,
    required this.quantidade,
    required this.descricao,
    required this.hash,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id']?.toString() ?? '',
      tipo: (json['tipo'] ?? '').toString(),
      origem: json['origem'] != null ? User.fromJson(json['origem']) : null,
      destino: json['destino'] != null ? User.fromJson(json['destino']) : null,
      quantidade: json['quantidade'] is int ? json['quantidade'] : int.tryParse(json['quantidade']?.toString() ?? '0') ?? 0,
      descricao: (json['descricao'] ?? '').toString(),
      hash: (json['hash'] ?? '').toString(),
      status: json['status']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
} 