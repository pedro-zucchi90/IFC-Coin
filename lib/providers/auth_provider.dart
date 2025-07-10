import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _error;
  User? _user;
  bool _isInitialized = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  bool get isLoggedIn => _authService.isLoggedIn;
  bool get isInitialized => _isInitialized;
  bool get isAdmin => _authService.isAdmin;
  bool get isProfessor => _authService.isProfessor;
  bool get isAluno => _authService.isAluno;

  // Inicializar o provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    try {
      await _authService.initialize();
      _user = _authService.currentUser;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String matricula, String senha) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _authService.login(matricula, senha);
      _user = response.user;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Registro
  Future<bool> registrar({
    required String nome,
    required String email,
    required String senha,
    required String matricula,
    required String role,
    String? curso,
    List<String> turmas = const [],
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _authService.registrar(
        nome: nome,
        email: email,
        senha: senha,
        matricula: matricula,
        role: role,
        curso: curso,
        turmas: turmas,
      );
      _user = response.user;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Atualizar dados do usuário
  Future<void> updateUserData() async {
    if (!isLoggedIn) return;
    
    try {
      _user = await _authService.updateUserData();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Verificar se o usuário tem uma determinada role
  bool hasRole(String role) {
    return _authService.hasRole(role);
  }

  // Método auxiliar para definir loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 