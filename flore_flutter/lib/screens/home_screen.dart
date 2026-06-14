import 'package:flutter/material.dart';
import 'orders_screen.dart';
import 'map_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf7f5f2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildHeroBanner(context),
              const SizedBox(height: 28),
              const Text('Acesso rápido', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1a5c52))),
              const SizedBox(height: 12),
              _buildQuickAccess(context),
              const SizedBox(height: 28),
              const Text('Próxima entrega', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1a5c52))),
              const SizedBox(height: 12),
              _buildNextDelivery(context),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Olá, bem-vinda!', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const Text('Florê', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF1a5c52), letterSpacing: -0.5)),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16)],
                ),
                child: const Icon(Icons.notifications_outlined, color: Color(0xFF2a7d70), size: 22),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Sair da conta', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1a5c52))),
                    content: const Text('Tem certeza que deseja sair?', style: TextStyle(color: Color(0xFF6b6b6b))),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar', style: TextStyle(color: Color(0xFF6b6b6b))),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
                        child: const Text('Sair', style: TextStyle(color: Color(0xFFd4541a), fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16)],
                ),
                child: const Icon(Icons.logout, color: Color(0xFF6b6b6b), size: 22),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a5c52), Color(0xFF2a7d70)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFd4541a), borderRadius: BorderRadius.circular(50)),
            child: const Text('MODA CIRCULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ),
          const SizedBox(height: 12),
          const Text('2 pedidos\nem trânsito', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
              child: const Text('Ver pedidos', style: TextStyle(color: Color(0xFF1a5c52), fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Row(
      children: [
        _QuickCard(icon: Icons.list_alt_outlined, label: 'Pedidos', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
        const SizedBox(width: 10),
        _QuickCard(icon: Icons.map_outlined, label: 'Rastreamento', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()))),
        const SizedBox(width: 10),
        _QuickCard(icon: Icons.notifications_outlined, label: 'Alertas', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()))),
      ],
    );
  }

  Widget _buildNextDelivery(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFe8f4f1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF2a7d70), size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vestido Azul com Flores', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1a5c52))),
                SizedBox(height: 2),
                Text('Hoje até 18h', style: TextStyle(color: Color(0xFF6b6b6b), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFfff0e8), borderRadius: BorderRadius.circular(50)),
            child: const Text('Em trânsito', style: TextStyle(color: Color(0xFFd4541a), fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16)],
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF2a7d70), size: 24),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1a5c52)), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
