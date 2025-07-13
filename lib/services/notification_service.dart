import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

const Color azulPrincipal = Color(0xFF1976D2);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Getters
  bool get isInitialized => _isInitialized;

  // Inicializar o serviço
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configurar notificações locais
      await _setupLocalNotifications();

      _isInitialized = true;
      // print('✅ Serviço de notificações inicializado com sucesso');
    } catch (e) {
      // print('❌ Erro ao inicializar serviço de notificações: $e');
    }
  }

  // Configurar notificações locais
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Mostrar notificação local
  Future<void> mostrarNotificacao({
    required String titulo,
    required String mensagem,
    Map<String, dynamic>? dados,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'ifc_coin_channel',
      'IFC Coin Notifications',
      channelDescription: 'Canal para notificações do IFC Coin',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: azulPrincipal,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      titulo,
      mensagem,
      platformChannelSpecifics,
      payload: dados != null ? jsonEncode(dados) : null,
    );
  }

  // Handler para quando a notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  // Navegar baseado no tipo de notificação
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final tipo = data['tipo'];
    
    switch (tipo) {
      case 'professor_aprovado':
        // print('🎉 Professor aprovado! Navegar para login...');
        break;
      case 'meta_concluida':
        // print('🎯 Meta concluída! Navegar para metas...');
        break;
      case 'nova_conquista':
        // print('🏆 Nova conquista! Navegar para conquistas...');
        break;
      default:
        // print('📱 Notificação recebida: $tipo');
    }
  }

  // Notificar aprovação de professor
  Future<void> notificarProfessorAprovado(String nomeProfessor) async {
    if (!_isInitialized) {
      await initialize();
    }
    await mostrarNotificacao(
      titulo: '🎉 Conta Aprovada!',
      mensagem: 'Parabéns $nomeProfessor! Sua solicitação foi aprovada e você já pode usar o sistema IFC Coin.',
      dados: {
        'tipo': 'professor_aprovado',
        'nome': nomeProfessor,
      },
    );
  }

  // Notificar conclusão de meta
  Future<void> notificarMetaConcluida(String nomeUsuario, String tituloMeta, int recompensa) async {
    if (!_isInitialized) {
      await initialize();
    }
    await mostrarNotificacao(
      titulo: '🎯 Meta Concluída!',
      mensagem: 'Parabéns $nomeUsuario! Você concluiu a meta "$tituloMeta" e ganhou $recompensa coins!',
      dados: {
        'tipo': 'meta_concluida',
        'nome': nomeUsuario,
        'metaTitulo': tituloMeta,
        'recompensa': recompensa.toString(),
      },
    );
  }

  // Notificar nova conquista
  Future<void> notificarNovaConquista(String nomeUsuario, String nomeConquista) async {
    if (!_isInitialized) {
      await initialize();
    }
    await mostrarNotificacao(
      titulo: '🏆 Nova Conquista!',
      mensagem: 'Parabéns $nomeUsuario! Você desbloqueou a conquista "$nomeConquista"!',
      dados: {
        'tipo': 'nova_conquista',
        'nome': nomeUsuario,
        'conquistaNome': nomeConquista,
      },
    );
  }
} 