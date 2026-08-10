import 'package:flutter/material.dart';
import '../models/delivery_order.dart';
import '../services/delivery_service.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  late Future<DeliveryResult<List<DeliveryOrder>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _deliveryService.getOrders();
  }

  Future<void> _reload() async {
    setState(() {
      _ordersFuture = _deliveryService.getOrders();
    });
    await _ordersFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf7f5f2),
      appBar: AppBar(
        title: const Text('Meus Pedidos', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<DeliveryResult<List<DeliveryOrder>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data;
          final orders = result?.data ?? const [];

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (result?.isFallback == true) ...[
                  _buildFallbackBanner(result!.errorMessage),
                  const SizedBox(height: 12),
                ],
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
        },
      ),
    );
  }

  Widget _buildFallbackBanner(String? message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFd4541a).withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.cloud_off_outlined, color: Color(0xFFd4541a), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message ?? 'Não foi possível carregar seus pedidos. Mostrando dados de exemplo.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6b6b6b)),
          ),
        ),
      ]),
    );
  }
}