import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

import '../services/fcm_service.dart';

class _NotifItem {
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final Future<void> Function()? simulate;
  const _NotifItem({required this.title, required this.body, required this.icon, required this.color, this.simulate});
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<_NotifItem> _history = [];
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  bool get _fcmAvailable => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  late final _types = [
    _NotifItem(
      title: 'Entrega em Trânsito',
      body: 'Seu vestido saiu para entrega. Previsão: hoje até 18h.',
      icon: Icons.local_shipping_outlined,
      color: const Color(0xFFd4541a),
      simulate: FCMService().simulateDeliveryAlert,
    ),
    _NotifItem(
      title: 'Peça no Armazém',
      body: 'Sua calça jeans chegou ao armazém Florê e está sendo preparada.',
      icon: Icons.warehouse_outlined,
      color: const Color(0xFF2a7d70),
      simulate: FCMService().simulateWarehouseAlert,
    ),
    _NotifItem(
      title: 'Favorito Disponível',
      body: 'Uma peça da sua lista de desejos voltou ao catálogo!',
      icon: Icons.favorite_outline,
      color: const Color(0xFF3d9e8f),
      simulate: FCMService().simulatePromoAlert,
    ),
    _NotifItem(
      title: 'Alerta Climático',
      body: 'Chuva intensa detectada. Sua entrega pode sofrer atraso.',
      icon: Icons.thunderstorm_outlined,
      color: const Color(0xFF1a5c52),
      simulate: FCMService().simulateWeatherAlert,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (_fcmAvailable) {
      _fcmSubscription = FCMService().onForegroundMessage.listen(_onRemoteMessage);
    }
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    super.dispose();
  }

  void _onRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    setState(() => _history.insert(
          0,
          _NotifItem(
            title: notification.title ?? 'Notificação Florê',
            body: notification.body ?? '',
            icon: Icons.notifications_active_outlined,
            color: const Color(0xFF2a7d70),
          ),
        ));
  }

  Future<void> _send(_NotifItem item) async {
    if (_fcmAvailable && FCMService().isInitialized) {
      await item.simulate?.call();
    }
    setState(() => _history.insert(0, item));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(item.icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: item.color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final fcmReady = _fcmAvailable && FCMService().isInitialized;
    return Scaffold(
      backgroundColor: const Color(0xFFf7f5f2),
      appBar: AppBar(title: const Text('Notificações', style: TextStyle(fontWeight: FontWeight.w700))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: fcmReady ? const Color(0xFFe8f4f1) : const Color(0xFFf1ede8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (fcmReady ? const Color(0xFF3d9e8f) : const Color(0xFF6b6b6b)).withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                Icon(
                  fcmReady ? Icons.check_circle_outline : Icons.info_outline,
                  color: fcmReady ? const Color(0xFF2a7d70) : const Color(0xFF6b6b6b),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fcmReady ? 'Firebase FCM inicializado' : 'FCM disponível apenas no Android por enquanto',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: fcmReady ? const Color(0xFF1a5c52) : const Color(0xFF6b6b6b),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            const Text('Disparar notificação', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1a5c52))),
            const SizedBox(height: 12),
            ..._types.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _send(item),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 24, offset: const Offset(0, 4))],
                    border: const Border(left: BorderSide(color: Color(0xFF2a7d70), width: 3)),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: item.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1a5c52))),
                          const SizedBox(height: 2),
                          Text(item.body, style: const TextStyle(fontSize: 11, color: Color(0xFF6b6b6b))),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF6b6b6b), size: 18),
                  ]),
                ),
              ),
            )),
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Histórico da sessão', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1a5c52))),
              const SizedBox(height: 12),
              ..._history.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Icon(item.icon, color: item.color, size: 16),
                  const SizedBox(width: 10),
                  Text(item.title, style: const TextStyle(fontSize: 13, color: Color(0xFF1e1e1e))),
                ]),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
