import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flore_flutter/models/app_user.dart';
import 'package:flore_flutter/screens/login_screen.dart';
import 'package:flore_flutter/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService authService;

  setUp(() {
    authService = MockAuthService();
  });

  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(authService: authService),
      routes: {'/home': (_) => const Scaffold(body: Text('Home'))},
    ));
  }

  testWidgets('exibe erros de validação quando os campos estão vazios', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
    verifyNever(() => authService.login(email: any(named: 'email'), password: any(named: 'password')));
  });

  testWidgets('exibe erro de e-mail inválido', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'nao-e-email');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('E-mail inválido'), findsOneWidget);
  });

  testWidgets('desabilita o botão e mostra spinner durante o loading', (tester) async {
    final completer = Completer<AppUser>();
    when(() => authService.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) => completer.future);

    await pumpLogin(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'priscila@flore.com.br');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Um segundo tap enquanto carrega não deve disparar uma nova chamada.
    await tester.tap(find.byType(CircularProgressIndicator), warnIfMissed: false);
    await tester.pump();
    verify(() => authService.login(email: any(named: 'email'), password: any(named: 'password'))).called(1);

    completer.complete(const AppUser(id: '1', name: 'Priscila', email: 'priscila@flore.com.br'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('mostra mensagem de erro quando credenciais são inválidas', (tester) async {
    when(() => authService.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(const AuthException(AuthErrorType.invalidCredentials, 'E-mail ou senha incorretos.'));

    await pumpLogin(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'priscila@flore.com.br');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');

    await tester.tap(find.text('Entrar'));
    await tester.pump();
    await tester.pump();

    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
  });
}
