import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flore_flutter/models/closet_item.dart';
import 'package:flore_flutter/providers/closet_provider.dart';
import 'package:flore_flutter/services/closet_service.dart';

class MockClosetService extends Mock implements ClosetService {}

void main() {
  late MockClosetService closetService;
  late ClosetProvider provider;

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
    const ClosetItem(
      id: '3',
      name: 'Vestido Longo Verde',
      category: 'Vestidos',
      price: 200,
      status: ClosetItemStatus.available,
      ownerId: '2',
      ownerName: 'Sophie Moreau',
    ),
  ];

  setUp(() {
    closetService = MockClosetService();
    provider = ClosetProvider(closetService: closetService);
  });

  test('marketplaceCategories retorna categorias únicas e ordenadas', () async {
    when(() => closetService.getMarketplace()).thenAnswer((_) async => pecas);

    await provider.loadMarketplace();

    expect(provider.marketplaceCategories, ['Calças', 'Vestidos']);
  });

  test('filteredMarketplace sem filtro retorna tudo', () async {
    when(() => closetService.getMarketplace()).thenAnswer((_) async => pecas);

    await provider.loadMarketplace();

    expect(provider.filteredMarketplace, hasLength(3));
  });

  test('filteredMarketplace aplica busca por nome (case-insensitive)', () async {
    when(() => closetService.getMarketplace()).thenAnswer((_) async => pecas);

    await provider.loadMarketplace();
    provider.setSearchQuery('VESTIDO');

    expect(provider.filteredMarketplace, hasLength(2));
    expect(provider.filteredMarketplace.every((i) => i.category == 'Vestidos'), isTrue);
  });

  test('filteredMarketplace aplica filtro de categoria', () async {
    when(() => closetService.getMarketplace()).thenAnswer((_) async => pecas);

    await provider.loadMarketplace();
    provider.setCategoryFilter('Calças');

    expect(provider.filteredMarketplace, hasLength(1));
    expect(provider.filteredMarketplace.first.name, 'Calça Wide Leg Preta');
  });

  test('filteredMarketplace combina busca e categoria', () async {
    when(() => closetService.getMarketplace()).thenAnswer((_) async => pecas);

    await provider.loadMarketplace();
    provider.setCategoryFilter('Vestidos');
    provider.setSearchQuery('longo');

    expect(provider.filteredMarketplace, hasLength(1));
    expect(provider.filteredMarketplace.first.name, 'Vestido Longo Verde');
  });

  test('buyItem remove a peça do marketplace em caso de sucesso', () async {
    when(() => closetService.getMarketplace()).thenAnswer((_) async => pecas);
    when(() => closetService.buyItem('1')).thenAnswer((_) async {});

    await provider.loadMarketplace();
    await provider.buyItem(pecas[0]);

    expect(provider.filteredMarketplace.any((i) => i.id == '1'), isFalse);
    expect(provider.buyingItemId, isNull);
  });

  test('buyItem propaga erro e limpa buyingItemId (não engole exceção)', () async {
    when(() => closetService.getMarketplace()).thenAnswer((_) async => pecas);
    when(() => closetService.buyItem('1'))
        .thenThrow(const ClosetException(ClosetErrorType.server, 'Não foi possível concluir a compra.'));

    await provider.loadMarketplace();

    await expectLater(() => provider.buyItem(pecas[0]), throwsA(isA<ClosetException>()));
    expect(provider.buyingItemId, isNull);
    expect(provider.filteredMarketplace.any((i) => i.id == '1'), isTrue);
  });

  test('createItem adiciona peça no início do meu closet', () async {
    final created = pecas[0];
    when(() => closetService.createItem(
          name: any(named: 'name'),
          category: any(named: 'category'),
          price: any(named: 'price'),
          description: any(named: 'description'),
        )).thenAnswer((_) async => created);

    await provider.createItem(name: created.name, category: created.category, price: created.price);

    expect(provider.myCloset, [created]);
  });
}
