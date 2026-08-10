import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Ajuste o caminho do import abaixo conforme a estrutura real do seu projeto
import 'package:flore_flutter/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Garante que cada teste começa sem sessão persistida de um teste anterior
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService.login', () {
    test('retorna AppUser e persiste token quando a API responde 200', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/auth/login');
        return http.Response(
          jsonEncode({
            'token': 'token-123',
            'user': {'id': 1, 'name': 'Gabriel', 'email': 'gabriel@flore.com'},
          }),
          200,
        );
      });

      final service = AuthService(client: client);
      final user = await service.login(email: 'gabriel@flore.com', password: '123456');

      expect(user.id, '1');
      expect(user.name, 'Gabriel');
      expect(await service.getToken(), 'token-123');
      expect(await service.isLoggedIn(), true);
    });

    test('lança AuthException(invalidCredentials) quando a API responde 401', () async {
      final client = MockClient((request) async => http.Response('', 401));
      final service = AuthService(client: client);

      expect(
            () => service.login(email: 'gabriel@flore.com', password: 'errada'),
        throwsA(isA<AuthException>().having((e) => e.type, 'type', AuthErrorType.invalidCredentials)),
      );
    });

    test('lança AuthException(server) quando a API responde 500', () async {
      final client = MockClient((request) async => http.Response('', 500));
      final service = AuthService(client: client);

      expect(
            () => service.login(email: 'gabriel@flore.com', password: '123456'),
        throwsA(isA<AuthException>().having((e) => e.type, 'type', AuthErrorType.server)),
      );
    });

    test('lança AuthException(network) quando não há conexão (SocketException)', () async {
      final client = MockClient((request) async {
        throw const SocketException('Sem conexão');
      });
      final service = AuthService(client: client);

      expect(
            () => service.login(email: 'gabriel@flore.com', password: '123456'),
        throwsA(isA<AuthException>().having((e) => e.type, 'type', AuthErrorType.network)),
      );
    });
  });

  group('AuthService.signup', () {
    test('lança AuthException(emailInUse) quando a API responde 409', () async {
      final client = MockClient((request) async => http.Response('', 409));
      final service = AuthService(client: client);

      expect(
            () => service.signup(name: 'Gabriel', email: 'gabriel@flore.com', password: '123456'),
        throwsA(isA<AuthException>().having((e) => e.type, 'type', AuthErrorType.emailInUse)),
      );
    });

    test('retorna AppUser quando a API responde 201', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'token': 'token-abc',
            'user': {'id': 2, 'name': 'Nova Usuária', 'email': 'nova@flore.com'},
          }),
          201,
        );
      });

      final service = AuthService(client: client);
      final user = await service.signup(name: 'Nova Usuária', email: 'nova@flore.com', password: '123456');

      expect(user.email, 'nova@flore.com');
      expect(await service.getToken(), 'token-abc');
    });
  });

  group('AuthService sessão', () {
    test('logout limpa token e usuário salvos', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'token': 'token-xyz',
            'user': {'id': 3, 'name': 'Fulano', 'email': 'fulano@flore.com'},
          }),
          200,
        );
      });

      final service = AuthService(client: client);
      await service.login(email: 'fulano@flore.com', password: '123456');
      expect(await service.isLoggedIn(), true);

      await service.logout();

      expect(await service.isLoggedIn(), false);
      expect(await service.getToken(), isNull);
      expect(await service.getCurrentUser(), isNull);
    });
  });
}