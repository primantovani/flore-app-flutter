import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/delivery_order.dart';
import '../models/delivery_point.dart';

class DeliveryService {
  static const String _baseUrl = 'https://flore-back.onrender.com';

  final http.Client _client;

  DeliveryService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<DeliveryOrder>> getOrders() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/api/orders'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => DeliveryOrder.fromJson(e)).toList();
      }
    } catch (_) {}
    return DeliveryOrder.mockOrders();
  }

  Future<List<DeliveryPoint>> getMapPoints() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/api/map-points'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => DeliveryPoint.fromJson(e)).toList();
      }
    } catch (_) {}
    return DeliveryPoint.mockPoints();
  }
}