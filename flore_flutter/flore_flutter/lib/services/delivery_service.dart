// lib/services/delivery_service.dart
//
// Integração com o back-end do Florê (flore-back).
// Em produção, substitua BASE_URL pela URL real do servidor.
// Os dados simulados espelham a estrutura real da API.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/delivery_model.dart';

class DeliveryService {
  // URL base do back-end Florê (Spring Boot)
  static const String _baseUrl = 'https://flore-back.onrender.com/api';

  // Retorna lista de pedidos ativos do usuário
  Future<List<DeliveryOrder>> getActiveOrders(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/orders?userId=$userId&status=active'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => DeliveryOrder.fromJson(e)).toList();
      }
    } catch (_) {
      // Fallback: dados simulados quando o servidor não está disponível
    }

    return _simulatedOrders();
  }

  // Retorna pontos no mapa (armazéns, entregas, parceiros)
  Future<List<DeliveryPoint>> getMapPoints() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/map-points'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => DeliveryPoint.fromJson(e)).toList();
      }
    } catch (_) {
      // Fallback simulado
    }

    return _simulatedMapPoints();
  }

  // ─── Dados simulados (fallback) ───────────────────────────────────────────

  List<DeliveryOrder> _simulatedOrders() {
    return [
      DeliveryOrder(
        orderId: 'FLR-2026-001',
        itemName: 'Jaqueta Jeans Vintage',
        status: 'Em trânsito',
        origin: 'Centro Florê - São Paulo',
        destination: 'Pinheiros, SP',
        estimatedDelivery: 'Hoje, até 18h',
        progress: 0.65,
        timeline: [
          DeliveryEvent(
            title: 'Pedido confirmado',
            description: 'Pagamento aprovado',
            time: '08:00',
            completed: true,
          ),
          DeliveryEvent(
            title: 'Saiu para entrega',
            description: 'Item retirado do centro Florê',
            time: '10:30',
            completed: true,
          ),
          DeliveryEvent(
            title: 'Em trânsito',
            description: 'Caminho para o destino',
            time: '13:45',
            completed: true,
          ),
          DeliveryEvent(
            title: 'Entregue',
            description: 'Aguardando entrega',
            time: 'Previsto 18:00',
            completed: false,
          ),
        ],
      ),
      DeliveryOrder(
        orderId: 'FLR-2026-002',
        itemName: 'Vestido Floral P',
        status: 'No centro Florê',
        origin: 'Vendedora Ana Lima',
        destination: 'Centro Florê - São Paulo',
        estimatedDelivery: 'Amanhã',
        progress: 0.3,
        timeline: [
          DeliveryEvent(
            title: 'Venda confirmada',
            description: 'Item comprado com sucesso',
            time: '15:20',
            completed: true,
          ),
          DeliveryEvent(
            title: 'Coletado pelo Florê',
            description: 'Retirado da vendedora',
            time: 'Previsto amanhã 10h',
            completed: false,
          ),
          DeliveryEvent(
            title: 'Entregue a você',
            description: '',
            time: 'Previsto em 2 dias',
            completed: false,
          ),
        ],
      ),
    ];
  }

  List<DeliveryPoint> _simulatedMapPoints() {
    return [
      DeliveryPoint(
        id: 'warehouse-sp',
        label: 'Centro Florê São Paulo',
        type: 'warehouse',
        latitude: -23.5505,
        longitude: -46.6333,
        status: 'Operando',
        estimatedTime: null,
      ),
      DeliveryPoint(
        id: 'delivery-001',
        label: 'Entrega FLR-2026-001',
        type: 'delivery',
        latitude: -23.5629,
        longitude: -46.6544,
        status: 'Em trânsito',
        estimatedTime: 'Hoje 18h',
      ),
      DeliveryPoint(
        id: 'partner-correios',
        label: 'Parceiro Logístico - Correios',
        type: 'partner',
        latitude: -23.5430,
        longitude: -46.6291,
        status: 'Disponível',
        estimatedTime: null,
      ),
      DeliveryPoint(
        id: 'partner-jadlog',
        label: 'Parceiro Logístico - Jadlog',
        type: 'partner',
        latitude: -23.5710,
        longitude: -46.6450,
        status: 'Disponível',
        estimatedTime: null,
      ),
    ];
  }
}
