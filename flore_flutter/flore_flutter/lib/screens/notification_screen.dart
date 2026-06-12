// lib/screens/notification_screen.dart
//
// Tela de demonstração do Firebase Cloud Messaging.
// Permite disparar notificações push simuladas para
// demonstrar os diferentes tipos de alerta do sistema Florê.

import 'package:flutter/material.dart';
import '../services/fcm_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FCMService _fcmService = FCMService();
  bool _initialized = false;
  String _statusMessage = 'Inicializando Firebase Messaging...';
  final List<_NotificationLog> _logs = [];

  static const Color _primary = Color(0xFF5C7A5C);
  static const Color _accent = Color(0xFFE8A87C);
  static const Color _background = Color(0xFFF5F0E8);

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    try {
      await _fcmService.initialize();
      setState(() {
        _initialized = true;
        _statusMessage = '✅ Firebase Messaging pronto';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '⚠️ FCM em modo simulado (sem Firebase configurado)';
        _initialized = true;
      });
    }
  }

  Future<void> _triggerNotification(
    String type,
    Future<void> Function() action,
  ) async {
    await action();
    setState(() {
      _logs.insert(
        0,
        _NotificationLog(type: type, time: _currentTime()),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notificação "$type" disparada!'),
        backgroundColor: _primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _currentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.notifications_outlined, size: 20),
            SizedBox(width: 8),
            Text('Notificações FCM',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status do FCM
            _buildStatusCard(),
            const SizedBox(height: 20),

            // Tipos de notificação
            Text(
              'Disparar Notificação Simulada',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
            const SizedBox(height: 12),

            _buildNotificationButton(
              icon: Icons.local_shipping,
              label: 'Entrega em Trânsito',
              description: 'Avisa que o pedido está a caminho',
              color: Colors.orange,
              onTap: _initialized
                  ? () => _triggerNotification(
                      'Entrega em Trânsito',
                      _fcmService.simulateDeliveryAlert)
                  : null,
            ),

            _buildNotificationButton(
              icon: Icons.warehouse,
              label: 'Item no Armazém',
              description: 'Confirma chegada ao centro Florê',
              color: _primary,
              onTap: _initialized
                  ? () => _triggerNotification(
                      'Item no Armazém',
                      _fcmService.simulateWarehouseAlert)
                  : null,
            ),

            _buildNotificationButton(
              icon: Icons.star_border,
              label: 'Item Favorito Disponível',
              description: 'Peça curtida voltou ao catálogo',
              color: _accent,
              onTap: _initialized
                  ? () => _triggerNotification(
                      'Favorito Disponível',
                      _fcmService.simulatePromoAlert)
                  : null,
            ),

            _buildNotificationButton(
              icon: Icons.thunderstorm_outlined,
              label: 'Alerta Climático',
              description: 'Chuva pode impactar entrega',
              color: Colors.blue,
              onTap: _initialized
                  ? () => _triggerNotification(
                      'Alerta Climático',
                      _fcmService.simulateWeatherAlert)
                  : null,
            ),

            const SizedBox(height: 24),

            // Log de notificações disparadas
            if (_logs.isNotEmpty) ...[
              Text(
                'Histórico desta sessão',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 8),
              ..._logs.map((log) => _buildLogItem(log)),
            ],

            const SizedBox(height: 20),

            // Explicação técnica
            _buildTechnicalNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _initialized ? _primary.withOpacity(0.3) : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _initialized ? Icons.cloud_done : Icons.cloud_sync,
            color: _initialized ? _primary : Colors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusMessage,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(description,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
              Icon(Icons.send_rounded, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogItem(_NotificationLog log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: _primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(log.type, style: const TextStyle(fontSize: 13))),
          Text(log.time,
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildTechnicalNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como funciona em produção',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Em produção, as notificações são disparadas pelo servidor Florê '
            'via Firebase Admin SDK. O app recebe os payloads FCM via '
            'FirebaseMessaging.onMessage (foreground) e '
            'onBackgroundMessage (background), exibindo-as como '
            'notificações locais com flutter_local_notifications.',
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _NotificationLog {
  final String type;
  final String time;
  _NotificationLog({required this.type, required this.time});
}
