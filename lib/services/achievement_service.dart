import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/achievement_model.dart';
import 'auth_service.dart';
import '../config.dart';

class AchievementService {
  // baseUrl vem do config.dart
  final AuthService _authService = AuthService();

  // Listar todas as conquistas disponíveis
  Future<List<Achievement>> listarConquistas({String? tipo, String? categoria}) async {
    try {
      await _authService.initialize();
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      String url = '$baseUrl/achievement/listar';
      List<String> params = [];
      
      if (tipo != null) params.add('tipo=$tipo');
      if (categoria != null) params.add('categoria=$categoria');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
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
        final List<dynamic> conquistasJson = data['conquistas'];
        return conquistasJson.map((json) => Achievement.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar conquistas');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Listar categorias disponíveis
  Future<List<String>> listarCategorias() async {
    try {
      await _authService.initialize();
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.get(
        Uri.parse('$baseUrl/achievement/categorias'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> categoriasJson = jsonDecode(response.body);
        return categoriasJson.map((categoria) => categoria.toString()).toList();
      } else {
        throw Exception('Erro ao carregar categorias');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Obter conquista específica
  Future<Achievement> obterConquista(String conquistaId) async {
    try {
      await _authService.initialize();
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.get(
        Uri.parse('$baseUrl/achievement/$conquistaId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Achievement.fromJson(data);
      } else {
        throw Exception('Erro ao carregar conquista');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Criar uma nova conquista (admin)
  Future<void> criarConquista({
    required String nome,
    required String descricao,
    required String tipo,
    String? categoria,
    String? icone,
    String? requisitos,
  }) async {
    try {
      await _authService.initialize();
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.post(
        Uri.parse('$baseUrl/achievement/criar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nome': nome,
          'descricao': descricao,
          'tipo': tipo,
          'categoria': categoria,
          'icone': icone,
          'requisitos': requisitos,
        }),
      );

      if (response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao criar conquista');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  // Editar uma conquista (admin)
  Future<void> editarConquista({
    required String conquistaId,
    required String nome,
    required String descricao,
    required String tipo,
    String? categoria,
    String? icone,
    String? requisitos,
  }) async {
    try {
      await _authService.initialize();
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      // Monta o body sem campos nulos
      final Map<String, dynamic> body = {
        'nome': nome,
        'descricao': descricao,
        'tipo': tipo,
      };
      if (categoria != null && categoria.isNotEmpty) body['categoria'] = categoria;
      if (icone != null && icone.isNotEmpty) body['icone'] = icone;
      if (requisitos != null && requisitos.isNotEmpty) body['requisitos'] = requisitos;

      final response = await http.put(
        Uri.parse('$baseUrl/achievement/$conquistaId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao editar conquista');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  // Deletar uma conquista (admin)
  Future<void> deletarConquista(String conquistaId) async {
    try {
      await _authService.initialize();
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.delete(
        Uri.parse('$baseUrl/achievement/$conquistaId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao deletar conquista');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }
} 