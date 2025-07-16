import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user_model.dart';
import '../config.dart';

// Serviço responsável por autenticação, registro, login, logout e gerenciamento de token
class AuthService {
  // Chaves para armazenamento local
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Singleton pattern para garantir uma única instância
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  User? _currentUser;

  // Getters para acessar token e usuário atual
  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null && !_isTokenExpired();

  // Verifica se o token JWT está expirado
  bool _isTokenExpired() {
    if (_token == null) return true;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      int expirationTime = decodedToken['exp'] * 1000; // Converter para milissegundos
      return DateTime.now().millisecondsSinceEpoch >= expirationTime;
    } catch (e) {
      return true;
    }
  }

  // Inicializa o serviço carregando dados do armazenamento local
  Future<void> initialize() async {
    await _loadStoredData();
  }

  // Carrega token e usuário do armazenamento local
  Future<void> _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(tokenKey);
      
      final userJson = prefs.getString(userKey);
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
      }

      // Se o token estiver expirado, faz logout
      if (_isTokenExpired()) {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  // Salva token e usuário no armazenamento local
  Future<void> _saveData(String token, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, token);
      await prefs.setString(userKey, jsonEncode(user.toJson()));
      
      _token = token;
      _currentUser = user;
    } catch (e) {
      throw Exception('Erro ao salvar dados de autenticação');
    }
  }

  // Realiza login do usuário
  Future<LoginResponse> login(String matricula, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(LoginRequest(
          matricula: matricula,
          senha: senha,
        ).toJson()),
      );
    
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        // Salva dados localmente
        await _saveData(loginResponse.token, loginResponse.user);
        return loginResponse;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erro no login');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  // Realiza registro de novo usuário
  Future<LoginResponse> registrar({
    required String nome,
    required String email,
    required String senha,
    required String matricula,
    required String role,
    String? curso,
    List<String> turmas = const [],
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/registro'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': senha,
          'matricula': matricula,
          'role': role,
          'curso': curso,
          'turmas': turmas,
        }),
      );
    
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Se for professor, não retorna token, só user
        if (role == 'professor') {
          return LoginResponse(
            token: '', // Token vazio para professores
            user: User.fromJson(data['user']),
          );
        }
        // Para aluno/admin, fluxo normal
        final loginResponse = LoginResponse.fromJson(data);
        // Salva dados localmente apenas se não for professor
        await _saveData(loginResponse.token, loginResponse.user);
        return loginResponse;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erro no registro');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  // Realiza logout do usuário
  Future<void> logout() async {
    try {
      // Chama endpoint de logout se necessário
      if (_token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
    } finally {
      // Limpa dados locais
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove(userKey);
      _token = null;
      _currentUser = null;
    }
  }

  // Atualiza dados do usuário logado
  Future<User> updateUserData() async {
    if (_token == null) {
      throw Exception('Usuário não autenticado');
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        // Atualiza dados locais
        await _saveData(_token!, user);
        return user;
      } else {
        throw Exception('Erro ao atualizar dados do usuário');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  // Verifica se o usuário tem uma determinada role
  bool hasRole(String role) {
    return _currentUser?.role == role;
  }

  // Getters para roles específicas
  bool get isAdmin => hasRole('admin');
  bool get isProfessor => hasRole('professor');
  bool get isAluno => hasRole('aluno');
} 