// lib/services/fcm_service.dart
//
// Configuração do Firebase Cloud Messaging (FCM).
// Gerencia permissões, token do dispositivo e exibição de
// notificações locais simulando alertas do sistema Florê.

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Handler de mensagens em background (obrigatório ser top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[FCM] Mensagem recebida em background: ${message.messageId}');
}

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'flore_alerts',
    'Alertas Florê',
    description: 'Notificações de entregas e alertas do sistema Florê',
    importance: Importance.high,
  );

  /// Inicializa FCM, solicita permissões e configura listeners.
  Future<void> initialize() async {
    // Registra handler de background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Solicita permissão ao usuário (iOS / Android 13+)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('[FCM] Permissão: ${settings.authorizationStatus}');

    // Inicializa notificações locais
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);

    // Listener: app em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listener: app aberto via notificação
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Obtém e imprime o token do dispositivo
    final token = await _fcm.getToken();
    print('[FCM] Token do dispositivo: $token');
  }

  /// Exibe notificação local quando app está em foreground
  void _handleForegroundMessage(RemoteMessage message) {
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
    print('[FCM] Notificação tocada: ${message.data}');
    // Aqui você pode navegar para uma tela específica com base em message.data
  }

  // ─── Notificações Simuladas ───────────────────────────────────────────────
  // Usadas para demonstração sem necessidade de servidor FCM real

  /// Simula alerta de entrega em trânsito
  Future<void> simulateDeliveryAlert() async {
    await _showLocalNotification(
      id: 1001,
      title: '🚚 Sua entrega está a caminho!',
      body: 'Jaqueta Jeans Vintage — previsão de chegada hoje até 18h.',
      payload: 'order:FLR-2026-001',
    );
  }

  /// Simula alerta de item disponível no centro Florê
  Future<void> simulateWarehouseAlert() async {
    await _showLocalNotification(
      id: 1002,
      title: '📦 Item chegou ao centro Florê',
      body: 'Vestido Floral P está no armazém e será enviado em breve.',
      payload: 'order:FLR-2026-002',
    );
  }

  /// Simula alerta de promoção / item favoritado disponível
  Future<void> simulatePromoAlert() async {
    await _showLocalNotification(
      id: 1003,
      title: '⭐ Item dos seus favoritos está disponível!',
      body: 'Uma peça que você curtiu voltou ao catálogo. Confira agora!',
      payload: 'screen:favorites',
    );
  }

  /// Simula alerta de condição climática impactando entrega
  Future<void> simulateWeatherAlert() async {
    await _showLocalNotification(
      id: 1004,
      title: '🌧️ Alerta climático — entrega pode atrasar',
      body: 'Chuva intensa em São Paulo. Estimativa de entrega ajustada.',
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
