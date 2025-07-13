import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'auth_service.dart';
import '../config.dart';

class AdminService {
  final AuthService _authService = AuthService();

  // Listar solicitações de professores
  Future<Map<String, dynamic>> listarSolicitacoesProfessores({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      String url = '$baseUrl/admin/solicitacoes-professores?page=$page&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> solicitacoesJson = data['solicitacoes'];
        final solicitacoes = solicitacoesJson.map((json) => User.fromJson(json)).toList();
        
        return {
          'solicitacoes': solicitacoes,
          'paginacao': data['paginacao'],
        };
      } else {
        throw Exception('Erro ao carregar solicitações');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Aprovar professor
  Future<void> aprovarProfessor(String professorId, {String? motivo}) async {
    try {
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/aprovar-professor/$professorId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'motivo': motivo,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Erro ao aprovar professor');
        } catch (_) {
          throw Exception('Erro ao aprovar professor');
        }
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  // Recusar professor
  Future<void> recusarProfessor(String professorId, {String? motivo}) async {
    try {
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/recusar-professor/$professorId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'motivo': motivo,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao recusar professor');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  // Obter estatísticas das solicitações
  Future<Map<String, int>> obterEstatisticasSolicitacoes() async {
    try {
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/estatisticas-solicitacoes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'pendentes': data['pendentes'],
          'aprovados': data['aprovados'],
          'recusados': data['recusados'],
          'total': data['total'],
        };
      } else {
        throw Exception('Erro ao carregar estatísticas');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
} 