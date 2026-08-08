import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flore_flutter/models/app_user.dart';
import 'package:flore_flutter/screens/signup_screen.dart';
import 'package:flore_flutter/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService authService;

  setUp(() {
    authService = MockAuthService();
  });

  Future<void> pumpSignup(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SignupScreen(authService: authService),
      routes: {'/home': (_) => const Scaffold(body: Text('Home'))},
    ));
  }

  testWidgets('exibe erros de validação quando os campos estão vazios', (tester) async {
    await pumpSignup(tester);

    await tester.tap(find.text('Criar minha conta'));
    await tester.pump();

    expect(find.text('Informe seu nome'), findsOneWidget);
    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
  });

  testWidgets('exibe erro de senha curta', (tester) async {
    await pumpSignup(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Priscila Mantovani');
    await tester.enterText(find.byType(TextFormField).at(1), 'priscila@flore.com.br');
    await tester.enterText(find.byType(TextFormField).at(2), '123');
    await tester.tap(find.text('Criar minha conta'));
    await tester.pump();

    expect(find.text('Mínimo de 6 caracteres'), findsOneWidget);
  });

  testWidgets('desabilita o botão e mostra spinner durante o loading', (tester) async {
    final completer = Completer<AppUser>();
    when(() => authService.signup(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) => completer.future);

    await pumpSignup(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Priscila Mantovani');
    await tester.enterText(find.byType(TextFormField).at(1), 'priscila@flore.com.br');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');

    await tester.tap(find.text('Criar minha conta'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const AppUser(id: '1', name: 'Priscila', email: 'priscila@flore.com.br'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('mostra mensagem de erro quando e-mail já está em uso', (tester) async {
    when(() => authService.signup(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(const AuthException(AuthErrorType.emailInUse, 'Já existe uma conta com esse e-mail.'));

    await pumpSignup(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Priscila Mantovani');
    await tester.enterText(find.byType(TextFormField).at(1), 'priscila@flore.com.br');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');

    await tester.tap(find.text('Criar minha conta'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Já existe uma conta com esse e-mail.'), findsOneWidget);
  });
}
