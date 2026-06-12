// lib/widgets/order_card.dart

import 'package:flutter/material.dart';
import '../models/delivery_model.dart';

class OrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  static const Color _primary = Color(0xFF5C7A5C);
  static const Color _accent = Color(0xFFE8A87C);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 10, bottom: 4, top: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nome do item
            Text(
              order.itemName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Status
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _statusColor(order.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 11,
                    color: _statusColor(order.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progresso
            LinearProgressIndicator(
              value: order.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_primary),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 6),

            // Previsão
            Row(
              children: [
                Icon(Icons.schedule, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.estimatedDelivery,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 10, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    if (status.toLowerCase().contains('trânsito')) return Colors.orange;
    if (status.toLowerCase().contains('entregue')) return Colors.green;
    if (status.toLowerCase().contains('armazém') ||
        status.toLowerCase().contains('centro')) return Color(0xFF5C7A5C);
    return Colors.grey;
  }
}
