import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';
import 'screens/tela_login.dart';
import 'screens/home.dart';

// Função principal do app Flutter
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o binding do Flutter está pronto
  
  // Inicializar serviço de notificações locais
  await NotificationService().initialize();
  
  runApp(const MyApp()); // Inicia o app
}

// Widget raiz do aplicativo
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider para gerenciar autenticação globalmente
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'IFC COIN',
        theme: ThemeData(
         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE5E5E5)),
        ),
        home: const AuthWrapper(), // Widget que decide tela inicial
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Widget que decide se mostra tela de login ou home
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Adicionar observer para detectar mudanças no estado do app
    WidgetsBinding.instance.addObserver(this);
    
    // Inicializa o AuthProvider ao abrir o app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  void dispose() {
    // Remover observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Quando o app volta ao foco (resumed), atualizar dados do usuário
    if (state == AppLifecycleState.resumed) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isLoggedIn) {
        // Atualizar dados silenciosamente quando o app volta ao foco
        authProvider.silentUpdateUserData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuta mudanças no AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Mostra loading enquanto inicializa
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Se logado, vai para Home, senão para Login
        if (authProvider.isLoggedIn) {
          return HomeScreen();
        }

        return const TelaLogin();
      },
    );
  }
}