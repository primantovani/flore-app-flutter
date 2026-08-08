import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flore_flutter/main.dart';
import 'package:flore_flutter/models/app_user.dart';
import 'package:flore_flutter/screens/login_screen.dart';
import 'package:flore_flutter/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fluxo: login -> home -> navegação entre abas', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final authService = MockAuthService();
    when(() => authService.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => const AppUser(id: '1', name: 'Priscila Mantovani', email: 'priscila@flore.com.br'));

    await tester.pumpWidget(MaterialApp(
      title: 'Florê',
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(authService: authService),
        '/home': (_) => const MainNavigation(),
      },
    ));
    await tester.pumpAndSettle();

    // Login
    await tester.enterText(find.byType(TextFormField).at(0), 'priscila@flore.com.br');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    // Home: bottom navigation com as 5 abas
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Início'), findsOneWidget);

    // Navega para Pedidos (usa dados mockados localmente, sem depender de rede)
    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
    expect(find.text('Meus Pedidos'), findsOneWidget);

    // Navega para Alertas (simulador local de notificações)
    await tester.tap(find.text('Alertas'));
    await tester.pumpAndSettle();

    // Volta para Início
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.text('Olá, bem-vinda!'), findsOneWidget);

    // Perfil e Mapa dependem de AuthService/ClosetService/geolocalização
    // reais (sem injeção de mock em MainNavigation) — cobertos pelos
    // testes widget isolados de profile_screen, não aqui, pra não deixar
    // este teste dependente de rede/permissões.
  });
}
