import 'package:flutter/material.dart';
import '../models/delivery_order.dart';
import '../widgets/status_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  final DeliveryOrder order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf7f5f2),
      appBar: AppBar(
        title: const Text('Detalhes do Pedido', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            const Text('Histórico de movimentação', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1a5c52))),
            const SizedBox(height: 14),
            _buildTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pedido #${order.id}', style: const TextStyle(color: Color(0xFF6b6b6b), fontSize: 12)),
              StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.itemName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1a5c52))),
          const SizedBox(height: 18),
          _InfoRow(icon: Icons.place_outlined, label: 'Origem', value: order.origin),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.flag_outlined, label: 'Destino', value: order.destination),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.schedule_outlined, label: 'Previsão', value: order.estimatedDelivery),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: order.progress,
              backgroundColor: const Color(0xFFf0f0f0),
              color: const Color(0xFF2a7d70),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 5),
          Text('${(order.progress * 100).toInt()}% concluído', style: const TextStyle(fontSize: 11, color: Color(0xFF6b6b6b))),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: order.timeline.asMap().entries.map((entry) {
        final i = entry.key;
        final event = entry.value;
        final isLast = i == order.timeline.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: event.completed ? const Color(0xFF2a7d70) : const Color(0xFFf0f0f0),
                  shape: BoxShape.circle,
                  border: event.completed ? null : Border.all(color: const Color(0xFFdddddd)),
                ),
                child: Icon(event.completed ? Icons.check : Icons.circle_outlined, color: event.completed ? Colors.white : const Color(0xFFdddddd), size: 12),
              ),
              if (!isLast) Container(width: 2, height: 48, color: event.completed ? const Color(0xFF2a7d70) : const Color(0xFFf0f0f0)),
            ]),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: event.completed ? const Color(0xFF1a5c52) : const Color(0xFF6b6b6b))),
                    Text(event.description, style: const TextStyle(fontSize: 12, color: Color(0xFF6b6b6b))),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 15, color: const Color(0xFF2a7d70)),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(color: Color(0xFF6b6b6b), fontSize: 12)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1e1e1e)))),
    ]);
  }
}
