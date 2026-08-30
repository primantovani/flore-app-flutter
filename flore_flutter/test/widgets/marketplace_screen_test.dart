import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flore_flutter/models/closet_item.dart';
import 'package:flore_flutter/providers/closet_provider.dart';
import 'package:flore_flutter/screens/marketplace_screen.dart';
import 'package:flore_flutter/services/closet_service.dart';

class MockClosetService extends Mock implements ClosetService {}

void main() {
  late MockClosetService closetService;

  final pecas = [
    const ClosetItem(
      id: '1',
      name: 'Vestido Floral Midi',
      category: 'Vestidos',
      price: 120,
      status: ClosetItemStatus.available,
      ownerId: '2',
      ownerName: 'Sophie Moreau',
    ),
    const ClosetItem(
      id: '2',
      name: 'Calça Wide Leg Preta',
      category: 'Calças',
      price: 85,
      status: ClosetItemStatus.available,
      ownerId: '3',
      ownerName: 'Gabriel Notari',
    ),
  ];

  setUp(() {
    closetService = MockClosetService();
  });

  Future<void> pumpMarketplace(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<ClosetProvider>(
        create: (_) => ClosetProvider(closetService: closetService),
        child: const MaterialApp(home: MarketplaceScreen()),
      ),
    );
  }

  testWidgets('lista as peças disponíveis de outras usuárias', (tester) async {
    when(() => closetService.getMarketplace()).thenAnswer((_) async => pecas);

    await pumpMarketplace(tester);
    await tester.pumpAndSettle();

    expect(find.text('Vestido Floral Midi'), findsOneWidget);
    expect(find.text('Calça Wide Leg Preta'), findsOneWidget);
  });

  testWidgets('filtra pela busca de nome (funcionalidade nova)', (tester) async {
    when(() => closetService.getMarketplace()).thenAnswer((_) async => pecas);

    await pumpMarketplace(tester);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'vestido');
    await tester.pumpAndSettle();

    expect(find.text('Vestido Floral Midi'), findsOneWidget);
    expect(find.text('Calça Wide Leg Preta'), findsNothing);
  });

  testWidgets('filtra por categoria via chip (funcionalidade nova)', (tester) async {
    when(() => closetService.getMarketplace()).thenAnswer((_) async => pecas);

    await pumpMarketplace(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calças'));
    await tester.pumpAndSettle();

    expect(find.text('Calça Wide Leg Preta'), findsOneWidget);
    expect(find.text('Vestido Floral Midi'), findsNothing);
  });

  testWidgets('mostra mensagem específica quando filtro não encontra nada', (tester) async {
    when(() => closetService.getMarketplace()).thenAnswer((_) async => pecas);

    await pumpMarketplace(tester);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'sapato');
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma peça encontrada'), findsOneWidget);
  });

  testWidgets('mostra estado de erro quando a API falha', (tester) async {
    when(() => closetService.getMarketplace())
        .thenThrow(const ClosetException(ClosetErrorType.network, 'Sem conexão com o servidor.'));

    await pumpMarketplace(tester);
    await tester.pumpAndSettle();

    expect(find.text('Sem conexão com o servidor.'), findsOneWidget);
  });
}
