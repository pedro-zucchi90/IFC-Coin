import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/goal_model.dart';
import 'auth_service.dart';
import '../config.dart';

class GoalService {
  // baseUrl vem do config.dart
  final AuthService _authService = AuthService();

  // Listar todas as metas disponíveis
  Future<List<Goal>> listarMetas({String? tipo}) async {
    try {
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      String url = '$baseUrl/goal/listar';
      if (tipo != null) {
        url += '?tipo=$tipo';
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
        final List<dynamic> metasJson = data['metas'];
        return metasJson.map((json) => Goal.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar metas');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Listar metas do usuário logado
  Future<List<Goal>> listarMinhasMetas() async {
    try {
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.get(
        Uri.parse('$baseUrl/goal/minhas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> metasJson = jsonDecode(response.body);
        return metasJson.map((json) => Goal.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar minhas metas');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Obter meta específica
  Future<Goal> obterMeta(String metaId) async {
    try {
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.get(
        Uri.parse('$baseUrl/goal/$metaId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Goal.fromJson(data);
      } else {
        throw Exception('Erro ao carregar meta');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Concluir uma meta
  Future<Map<String, dynamic>> concluirMeta({
    required String metaId,
    String? evidenciaTexto,
    String? comentario,
    File? evidenciaArquivo,
  }) async {
    try {
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/goal/concluir/$metaId'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Adicionar campos de texto
      request.fields['evidenciaTexto'] = evidenciaTexto ?? '';
      request.fields['comentario'] = comentario ?? '';

      // Adicionar arquivo se fornecido
      if (evidenciaArquivo != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'evidenciaArquivo', // <-- nome do campo corrigido aqui
            evidenciaArquivo.path,
          ),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseData);
        return {
          'message': data['message'],
          'requerAprovacao': data.containsKey('requerAprovacao') ? data['requerAprovacao'] : false,
        };
      } else {
        final errorData = jsonDecode(responseData);
        throw Exception(errorData['message'] ?? 'Erro ao concluir meta');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  // Editar uma meta (admin)
  Future<void> editarMeta({
    required String metaId,
    required String titulo,
    required String descricao,
    required String tipo,
    required int requisito,
    required int recompensa,
    bool requerAprovacao = false,
  }) async {
    try {
      final token = _authService.token;
      final user = _authService.currentUser;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.put(
        Uri.parse('$baseUrl/goal/$metaId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'titulo': titulo,
          'descricao': descricao,
          'tipo': tipo,
          'requisito': requisito,
          'recompensa': recompensa,
          'requerAprovacao': requerAprovacao,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao editar meta');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  // Deletar uma meta (admin)
  Future<void> deletarMeta(String metaId) async {
    try {
      final token = _authService.token;
      final user = _authService.currentUser;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.delete(
        Uri.parse('$baseUrl/goal/$metaId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao deletar meta');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  // Criar uma nova meta (admin)
  Future<void> criarMeta({
    required String titulo,
    required String descricao,
    required String tipo,
    required int requisito,
    required int recompensa,
    bool requerAprovacao = false,
  }) async {
    try {
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.post(
        Uri.parse('$baseUrl/goal/criar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'titulo': titulo,
          'descricao': descricao,
          'tipo': tipo,
          'requisito': requisito,
          'recompensa': recompensa,
          'requerAprovacao': requerAprovacao,
        }),
      );

      if (response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao criar meta');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  // Listar solicitações de conclusão de meta (admin/professor)
  Future<List<dynamic>> listarSolicitacoesConclusao({String? status}) async {
    final token = _authService.token;
    if (token == null) throw Exception('Usuário não autenticado');
    String url = '$baseUrl/goal/solicitacoes';
    if (status != null) {
      url += '?status=$status';
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao carregar solicitações');
    }
  }

  // Aprovar solicitação de conclusão de meta
  Future<void> aprovarSolicitacaoConclusao(String solicitacaoId, {String? resposta}) async {
    final token = _authService.token;
    if (token == null) throw Exception('Usuário não autenticado');
    final response = await http.post(
      Uri.parse('$baseUrl/goal/solicitacoes/$solicitacaoId/aprovar'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'resposta': resposta}),
    );
    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Erro ao aprovar solicitação');
    }
  }

  // Recusar solicitação de conclusão de meta
  Future<void> recusarSolicitacaoConclusao(String solicitacaoId, {String? resposta}) async {
    final token = _authService.token;
    if (token == null) throw Exception('Usuário não autenticado');
    final response = await http.post(
      Uri.parse('$baseUrl/goal/solicitacoes/$solicitacaoId/recusar'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'resposta': resposta}),
    );
    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Erro ao recusar solicitação');
    }
  }
} 