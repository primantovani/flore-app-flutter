import 'package:flutter/material.dart';
import '../models/delivery_order.dart';
import 'status_badge.dart';

class OrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final VoidCallback? onTap;
  const OrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 24, offset: const Offset(0, 4))],
          border: const Border(left: BorderSide(color: Color(0xFF2a7d70), width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(order.itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1a5c52)))),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.schedule_outlined, size: 13, color: Color(0xFF6b6b6b)),
              const SizedBox(width: 4),
              Text(order.estimatedDelivery, style: const TextStyle(color: Color(0xFF6b6b6b), fontSize: 12)),
            ]),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: order.progress,
                backgroundColor: const Color(0xFFf0f0f0),
                color: const Color(0xFF2a7d70),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 4),
            Text('${(order.progress * 100).toInt()}% concluído', style: const TextStyle(fontSize: 11, color: Color(0xFF6b6b6b))),
          ],
        ),
      ),
    );
  }
}
