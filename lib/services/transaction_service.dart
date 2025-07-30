import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import 'auth_service.dart';
import '../config.dart';

class TransactionService {
  final AuthService _authService = AuthService();

  // Listar histórico de transações do usuário logado
  Future<List<Transaction>> listarHistorico({int page = 1, int limit = 20}) async {
    final token = _authService.token;
    final userId = _authService.currentUser?.id;
    if (token == null) throw Exception('Usuário não autenticado');
    final response = await http.get(
      Uri.parse('$baseUrl/transaction/historico?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> transacoesJson = data['transacoes'];
      final transacoes = transacoesJson.map((json) => Transaction.fromJson(json)).toList();
      // Filtrar apenas as transações do usuário logado
      if (userId != null) {
        return transacoes.where((t) =>
          (t.origem?.id == userId) || (t.destino?.id == userId)
        ).toList();
      }
      return transacoes;
    } else {
      throw Exception('Erro ao carregar histórico de transações');
    }
  }

  // Listar todas as transações (para admin)
  Future<List<Transaction>> listarTodasTransacoes({int page = 1, int limit = 100}) async {
    final token = _authService.token;
    if (token == null) throw Exception('Usuário não autenticado');
    
    final response = await http.get(
      Uri.parse('$baseUrl/transaction/todas?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> transacoesJson = data['transacoes'];
      final transacoes = transacoesJson.map((json) => Transaction.fromJson(json)).toList();
      
      return transacoes;
    } else {
      throw Exception('Erro ao carregar transações');
    }
  }

  // Transferir coins para outro usuário
  Future<Transaction> transferir({required String destinoMatricula, required int quantidade, String? descricao}) async {
    final token = _authService.token;
    if (token == null) throw Exception('Usuário não autenticado');
    final response = await http.post(
      Uri.parse('$baseUrl/transaction/transferir'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'destinoMatricula': destinoMatricula,
        'quantidade': quantidade,
        'descricao': descricao,
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Transaction.fromJson(data['transacao']);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Erro ao transferir coins');
    }
  }

  // Aprovar transferência (admin)
  Future<void> aprovarTransferencia(String transacaoId) async {
    final token = _authService.token;
    if (token == null) throw Exception('Usuário não autenticado');
    final response = await http.post(
      Uri.parse('$baseUrl/transaction/$transacaoId/aprovar'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Erro ao aprovar transferência');
    }
  }

  // Recusar transferência (admin)
  Future<void> recusarTransferencia(String transacaoId, {String? motivo}) async {
    final token = _authService.token;
    if (token == null) throw Exception('Usuário não autenticado');
    final response = await http.post(
      Uri.parse('$baseUrl/transaction/$transacaoId/recusar'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'motivo': motivo}),
    );
    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Erro ao recusar transferência');
    }
  }

  // Verifica se o usuário pode transferir qualquer valor (admin/professor)
  bool podeTransferirQualquerValor(String role) {
    return role == 'admin' || role == 'professor';
  }
} 