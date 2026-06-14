import 'package:flutter/material.dart';
import '../models/delivery_order.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = DeliveryOrder.mockOrders();
    return Scaffold(
      backgroundColor: const Color(0xFFf7f5f2),
      appBar: AppBar(
        title: const Text('Meus Pedidos', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFe8f4f1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3d9e8f).withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.inventory_2_outlined, color: Color(0xFF2a7d70), size: 18),
              const SizedBox(width: 10),
              Text('${orders.length} peças rastreadas', style: const TextStyle(color: Color(0xFF1a5c52), fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 16),
          ...orders.map((order) => OrderCard(
            order: order,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))),
          )),
        ],
      ),
    );
  }
}
