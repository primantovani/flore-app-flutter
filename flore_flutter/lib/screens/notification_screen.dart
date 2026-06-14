import 'package:flutter/material.dart';

class _NotifItem {
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  const _NotifItem({required this.title, required this.body, required this.icon, required this.color});
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<_NotifItem> _history = [];

  final _types = const [
    _NotifItem(title: 'Entrega em Trânsito', body: 'Seu vestido saiu para entrega. Previsão: hoje até 18h.', icon: Icons.local_shipping_outlined, color: Color(0xFFd4541a)),
    _NotifItem(title: 'Peça no Armazém', body: 'Sua calça jeans chegou ao armazém Florê e está sendo preparada.', icon: Icons.warehouse_outlined, color: Color(0xFF2a7d70)),
    _NotifItem(title: 'Favorito Disponível', body: 'Uma peça da sua lista de desejos voltou ao catálogo!', icon: Icons.favorite_outline, color: Color(0xFF3d9e8f)),
    _NotifItem(title: 'Alerta Climático', body: 'Chuva intensa detectada. Sua entrega pode sofrer atraso.', icon: Icons.thunderstorm_outlined, color: Color(0xFF1a5c52)),
  ];

  void _send(_NotifItem item) {
    setState(() => _history.insert(0, item));
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
                color: const Color(0xFFe8f4f1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3d9e8f).withValues(alpha: 0.3)),
              ),
              child: const Row(children: [
                Icon(Icons.check_circle_outline, color: Color(0xFF2a7d70), size: 18),
                SizedBox(width: 8),
                Text('Firebase FCM inicializado', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1a5c52))),
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
