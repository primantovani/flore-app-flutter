// lib/services/fcm_service.dart
//
// Configuração do Firebase Cloud Messaging (FCM).
// Gerencia permissões, token do dispositivo e exibição de
// notificações locais simulando alertas do sistema Florê.

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[FCM] Mensagem recebida em background: ${message.messageId}');
}

class FCMService {
  FCMService._internal();
  static final FCMService instance = FCMService._internal();
  factory FCMService() => instance;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final _foregroundMessages = StreamController<RemoteMessage>.broadcast();

  bool isInitialized = false;

  /// Mensagens push recebidas de verdade com o app em primeiro plano.
  Stream<RemoteMessage> get onForegroundMessage => _foregroundMessages.stream;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'flore_alerts',
    'Alertas Florê',
    description: 'Notificações de entregas e alertas do sistema Florê',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('[FCM] Permissao: ${settings.authorizationStatus}');

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final token = await _fcm.getToken();
    print('[FCM] Token do dispositivo: $token');
    isInitialized = true;
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _foregroundMessages.add(message);

    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('[FCM] Notificacao tocada: ${message.data}');
  }

  Future<void> simulateDeliveryAlert() async {
    await _showLocalNotification(
      id: 1001,
      title: 'Sua entrega esta a caminho!',
      body: 'Jaqueta Jeans Vintage - previsao de chegada hoje ate 18h.',
      payload: 'order:FLR-2026-001',
    );
  }

  Future<void> simulateWarehouseAlert() async {
    await _showLocalNotification(
      id: 1002,
      title: 'Item chegou ao centro Flore',
      body: 'Vestido Floral P esta no armazem e sera enviado em breve.',
      payload: 'order:FLR-2026-002',
    );
  }

  Future<void> simulatePromoAlert() async {
    await _showLocalNotification(
      id: 1003,
      title: 'Item dos seus favoritos esta disponivel!',
      body: 'Uma peca que voce curtiu voltou ao catalogo. Confira agora!',
      payload: 'screen:favorites',
    );
  }

  Future<void> simulateWeatherAlert() async {
    await _showLocalNotification(
      id: 1004,
      title: 'Alerta climatico - entrega pode atrasar',
      body: 'Chuva intensa em Sao Paulo. Estimativa de entrega ajustada.',
      payload: 'order:FLR-2026-001',
    );
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
}
