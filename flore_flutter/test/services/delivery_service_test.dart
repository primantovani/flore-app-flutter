import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Ajuste o caminho do import abaixo conforme a estrutura real do seu projeto
import 'package:flore_flutter/services/delivery_service.dart';
import 'package:flore_flutter/models/delivery_order.dart';
import 'package:flore_flutter/models/delivery_point.dart';

void main() {
  group('DeliveryService.getOrders', () {
    test('retorna a lista real quando a API responde 200', () async {
      final mockOrderJson = {
        'id': '099',
        'itemName': 'Jaqueta Jeans',
        'status': 'Em trânsito',
        'origin': 'Armazém Florê - SP',
        'destination': 'Rua Teste, 123 - SP',
        'estimatedDelivery': 'Hoje, até 20h',
        'progress': 0.5,
        'timeline': [],
      };

      final client = MockClient((request) async {
        expect(request.url.path, '/api/orders');
        return http.Response(jsonEncode([mockOrderJson]), 200);
      });

      final service = DeliveryService(client: client);
      final result = await service.getOrders();

      expect(result.isFallback, isFalse);
      expect(result.errorMessage, isNull);
      expect(result.data, hasLength(1));
      expect(result.data.first.id, '099');
      expect(result.data.first.itemName, 'Jaqueta Jeans');
    });

    test('cai no fallback mockado e expõe o erro quando a API responde erro', () async {
      final client = MockClient((request) async {
        return http.Response('erro interno', 500);
      });

      final service = DeliveryService(client: client);
      final result = await service.getOrders();

      expect(result.isFallback, isTrue);
      expect(result.errorMessage, isNotNull);
      expect(result.data, equals(isA<List<DeliveryOrder>>()));
      expect(result.data, hasLength(DeliveryOrder.mockOrders().length));
    });

    test('cai no fallback mockado e expõe o erro quando o client lança exceção (sem rede)', () async {
      final client = MockClient((request) async {
        throw Exception('Falha de conexão simulada');
      });

      final service = DeliveryService(client: client);
      final result = await service.getOrders();

      expect(result.isFallback, isTrue);
      expect(result.errorMessage, isNotNull);
      expect(result.data, hasLength(DeliveryOrder.mockOrders().length));
    });
  });

  group('DeliveryService.getMapPoints', () {
    test('retorna os pontos reais quando a API responde 200', () async {
      final mockPointJson = {
        'id': 'x1',
        'label': 'Ponto Teste',
        'type': 'delivery',
        'latitude': -23.55,
        'longitude': -46.63,
        'status': 'Em trânsito',
        'estimatedArrival': 'Hoje 18h',
      };

      final client = MockClient((request) async {
        expect(request.url.path, '/api/map-points');
        return http.Response(jsonEncode([mockPointJson]), 200);
      });

      final service = DeliveryService(client: client);
      final result = await service.getMapPoints();

      expect(result.isFallback, isFalse);
      expect(result.data, hasLength(1));
      expect(result.data.first.id, 'x1');
      expect(result.data.first.label, 'Ponto Teste');
    });

    test('cai no fallback mockado e expõe o erro quando a API responde erro', () async {
      final client = MockClient((request) async {
        return http.Response('erro interno', 500);
      });

      final service = DeliveryService(client: client);
      final result = await service.getMapPoints();

      expect(result.isFallback, isTrue);
      expect(result.errorMessage, isNotNull);
      expect(result.data, hasLength(DeliveryPoint.mockPoints().length));
    });
  });
}
