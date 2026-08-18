import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:flore_flutter/services/auth_service.dart';
import 'package:flore_flutter/services/closet_service.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockHttpClient client;
  late MockAuthService authService;
  late ClosetService closetService;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://flore-back.onrender.com'));
  });

  setUp(() {
    client = MockHttpClient();
    authService = MockAuthService();
    when(() => authService.getToken()).thenAnswer((_) async => 'test-token');
    closetService = ClosetService(client: client, authService: authService);
  });

  group('getMyCloset', () {
    test('retorna a lista de peças quando a API responde 200', () async {
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode([
            {'id': '1', 'name': 'Vestido Floral Midi', 'category': 'Vestidos', 'price': 120, 'status': 'available', 'ownerId': '1', 'ownerName': 'Priscila'}
          ]),
          200,
        ),
      );

      final items = await closetService.getMyCloset();

      expect(items, hasLength(1));
      expect(items.first.name, 'Vestido Floral Midi');
      expect(items.first.isAvailable, isTrue);
    });

    test('lança ClosetException(unauthorized) quando a API responde 401', () async {
      when(() => client.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 401));

      expect(
        () => closetService.getMyCloset(),
        throwsA(isA<ClosetException>().having((e) => e.type, 'type', ClosetErrorType.unauthorized)),
      );
    });

    test('lança ClosetException(network) quando não há conexão', () async {
      when(() => client.get(any(), headers: any(named: 'headers')))
          .thenThrow(const SocketException('Failed host lookup'));

      expect(
        () => closetService.getMyCloset(),
        throwsA(isA<ClosetException>().having((e) => e.type, 'type', ClosetErrorType.network)),
      );
    });
  });

  group('markAsSold', () {
    test('completa sem erro quando a API responde 200', () async {
      when(() => client.patch(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 200));

      await expectLater(closetService.markAsSold('1'), completes);
    });

    test('lança ClosetException(notFound) quando a peça não existe', () async {
      when(() => client.patch(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 404));

      expect(
        () => closetService.markAsSold('999'),
        throwsA(isA<ClosetException>().having((e) => e.type, 'type', ClosetErrorType.notFound)),
      );
    });
  });
}
