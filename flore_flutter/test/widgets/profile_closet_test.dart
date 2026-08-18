import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flore_flutter/models/app_user.dart';
import 'package:flore_flutter/models/closet_item.dart';
import 'package:flore_flutter/screens/profile_screen.dart';
import 'package:flore_flutter/services/auth_service.dart';
import 'package:flore_flutter/services/closet_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockClosetService extends Mock implements ClosetService {}

void main() {
  late MockAuthService authService;
  late MockClosetService closetService;

  const user = AppUser(id: '1', name: 'Priscila Mantovani', email: 'priscila@flore.com.br');

  final pecas = [
    const ClosetItem(
      id: '1',
      name: 'Vestido Floral Midi',
      category: 'Vestidos',
      price: 120,
      status: ClosetItemStatus.available,
      ownerId: '1',
      ownerName: 'Priscila Mantovani',
    ),
    const ClosetItem(
      id: '2',
      name: 'Calça Wide Leg Preta',
      category: 'Calças',
      price: 85,
      status: ClosetItemStatus.sold,
      ownerId: '1',
      ownerName: 'Priscila Mantovani',
    ),
  ];

  setUp(() {
    authService = MockAuthService();
    closetService = MockClosetService();
    when(() => authService.getCurrentUser()).thenAnswer((_) async => user);
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProfileScreen(authService: authService, closetService: closetService),
    ));
  }

  testWidgets('renderiza a lista do closet com dados de exemplo', (tester) async {
    when(() => closetService.getMyCloset()).thenAnswer((_) async => pecas);

    await pumpProfile(tester);
    await tester.pumpAndSettle();

    expect(find.text('Vestido Floral Midi'), findsOneWidget);
    expect(find.text('Calça Wide Leg Preta'), findsOneWidget);
    expect(find.text('À venda'), findsOneWidget);
    expect(find.text('Vendido'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // peças no closet
    expect(find.text('1'), findsOneWidget); // peças vendidas
  });

  testWidgets('mostra estado vazio quando não há peças', (tester) async {
    when(() => closetService.getMyCloset()).thenAnswer((_) async => []);

    await pumpProfile(tester);
    await tester.pumpAndSettle();

    expect(find.text('Seu closet está vazio. Cadastre a primeira peça!'), findsOneWidget);
  });

  testWidgets('mostra estado de erro quando a API falha', (tester) async {
    when(() => closetService.getMyCloset())
        .thenThrow(const ClosetException(ClosetErrorType.network, 'Sem conexão com o servidor.'));

    await pumpProfile(tester);
    await tester.pumpAndSettle();

    expect(find.text('Sem conexão com o servidor.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });
}
