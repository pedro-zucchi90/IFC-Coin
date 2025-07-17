import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  
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
  Future<Map<String, dynamic>> login(String matricula, String senha) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _authService.login(matricula, senha);
      _user = response.user;
      
      notifyListeners();
      return {
        'success': true,
        'showApprovalNotification': response.showApprovalNotification,
      };
    } catch (e) {
      String msg = e.toString().toLowerCase();
      if (msg.contains('matrícula') || msg.contains('senha') || msg.contains('incorret')) {
        _error = 'Matrícula ou senha incorretos';
      } else {
        _error = e.toString(); // Mostra o erro detalhado do backend
      }
      notifyListeners();
      return {
        'success': false,
        'showApprovalNotification': false,
      };
    } finally {
      _setLoading(false);
      notifyListeners(); // Garante atualização mesmo em erro
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
      
      // Se for professor, não fazer login automático (aguarda aprovação)
      if (role == 'professor') {
        // Não fazer login automático, mas retornar true para mostrar sucesso
        return true; // Retorna true para mostrar mensagem de sucesso
      }
      
      // Para alunos e admins, fazer login normal
      _user = response.user;
      
      notifyListeners();
      return true;
    } catch (e) {
      String msg = e.toString().toLowerCase();
      if (msg.contains('matrícula') || msg.contains('email') || msg.contains('já cadastrad') || msg.contains('em uso')) {
        _error = 'Matrícula ou email já estão em uso';
      } else if (msg.contains('senha')) {
        _error = 'A senha deve ter pelo menos 6 caracteres';
      } else {
        _error = e.toString(); // Mostra o erro detalhado do backend
      }
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
      notifyListeners(); // Garante atualização mesmo em erro
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