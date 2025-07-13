import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user_model.dart';
import '../config.dart';

class AuthService {
  // Para desenvolvimento local, use o IP da sua máquina
  // Você pode descobrir seu IP com: ipconfig no Windows
  // baseUrl vem do config.dart
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  User? _currentUser;

  // Getters
  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null && !_isTokenExpired();

  // Verificar se o token está expirado
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

  // Inicializar o serviço (chamado no app startup)
  Future<void> initialize() async {
    await _loadStoredData();
  }

  // Carregar dados armazenados
  Future<void> _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(tokenKey);
      
      final userJson = prefs.getString(userKey);
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
      }

      // Se o token estiver expirado, limpar dados
      if (_isTokenExpired()) {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  // Salvar dados localmente
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

  // Login
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
        
        // Salvar dados localmente
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

  // Registro de usuário
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
        
        // Salvar dados localmente apenas se não for professor
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

  // Logout
  Future<void> logout() async {
    try {
      // Chamar endpoint de logout se necessário
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
      // Limpar dados locais
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove(userKey);
      
      _token = null;
      _currentUser = null;
    }
  }

  // Atualizar dados do usuário
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
        
        // Atualizar dados locais
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

  // Verificar se o usuário tem uma determinada role
  bool hasRole(String role) {
    return _currentUser?.role == role;
  }

  // Verificar se o usuário é admin
  bool get isAdmin => hasRole('admin');

  // Verificar se o usuário é professor
  bool get isProfessor => hasRole('professor');

  // Verificar se o usuário é aluno
  bool get isAluno => hasRole('aluno');
} 