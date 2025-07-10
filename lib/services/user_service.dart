import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  static const String baseUrl = 'http://192.168.1.102:3000/api';
  final AuthService _authService = AuthService();

  // Atualizar perfil do usuário
  Future<bool> atualizarPerfil({
    required String nome,
    required String email,
    String? curso,
  }) async {
    try {
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.put(
        Uri.parse('$baseUrl/user/perfil'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'curso': curso,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao atualizar perfil');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  // Obter saldo do usuário
  Future<int> obterSaldo() async {
    try {
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      final response = await http.get(
        Uri.parse('$baseUrl/user/saldo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['saldo'];
      } else {
        throw Exception('Erro ao obter saldo');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  // Upload de foto de perfil
  Future<String> uploadFotoPerfil(File imageFile) async {
    try {
      final token = _authService.token;
      if (token == null) throw Exception('Usuário não autenticado');

      // Criar request multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user/foto-perfil'),
      );

      // Adicionar headers
      request.headers['Authorization'] = 'Bearer $token';

      // Adicionar arquivo
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          imageFile.path,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        // Retornar URL completa da foto
        return '$baseUrl${data['fotoPerfil']}';
      } else {
        final errorData = jsonDecode(responseData);
        throw Exception(errorData['message'] ?? 'Erro ao fazer upload da foto');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }
} 