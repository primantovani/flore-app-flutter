import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/delivery_order.dart';
import '../models/delivery_point.dart';

/// Resultado de uma chamada de rede que pode cair no fallback mockado.
/// Antes o fallback acontecia em silêncio (Melhoria D); agora a tela sabe
/// que os dados exibidos não são reais e por quê.
class DeliveryResult<T> {
  final T data;
  final bool isFallback;
  final String? errorMessage;

  const DeliveryResult({required this.data, this.isFallback = false, this.errorMessage});
}

class DeliveryService {
  static const String _baseUrl = AppConfig.apiBaseUrl;

  final http.Client _client;

  DeliveryService({http.Client? client}) : _client = client ?? http.Client();

  Future<DeliveryResult<List<DeliveryOrder>>> getOrders() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/api/orders'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return DeliveryResult(data: data.map((e) => DeliveryOrder.fromJson(e)).toList());
      }
      return _ordersFallback('Não foi possível carregar seus pedidos (erro ${response.statusCode}).');
    } on TimeoutException {
      return _ordersFallback('Tempo de conexão esgotado.');
    } on SocketException {
      return _ordersFallback('Sem conexão com o servidor.');
    } catch (_) {
      return _ordersFallback('Não foi possível carregar seus pedidos.');
    }
  }

  Future<DeliveryResult<List<DeliveryPoint>>> getMapPoints() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/api/map-points'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return DeliveryResult(data: data.map((e) => DeliveryPoint.fromJson(e)).toList());
      }
      return _mapPointsFallback('Não foi possível carregar os pontos logísticos (erro ${response.statusCode}).');
    } on TimeoutException {
      return _mapPointsFallback('Tempo de conexão esgotado.');
    } on SocketException {
      return _mapPointsFallback('Sem conexão com o servidor.');
    } catch (_) {
      return _mapPointsFallback('Não foi possível carregar os pontos logísticos.');
    }
  }

  DeliveryResult<List<DeliveryOrder>> _ordersFallback(String message) {
    return DeliveryResult(
      data: DeliveryOrder.mockOrders(),
      isFallback: true,
      errorMessage: '$message Mostrando dados de exemplo.',
    );
  }

  DeliveryResult<List<DeliveryPoint>> _mapPointsFallback(String message) {
    return DeliveryResult(
      data: DeliveryPoint.mockPoints(),
      isFallback: true,
      errorMessage: '$message Mostrando dados de exemplo.',
    );
  }
}
