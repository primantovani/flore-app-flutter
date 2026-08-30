import 'package:flutter/foundation.dart';

import '../models/closet_item.dart';
import '../services/closet_service.dart';

enum ClosetLoadState { idle, loading, loaded, error }

/// Estado compartilhado do closet circular: "Meu Closet" (Perfil) e
/// "Marketplace" (peças de outras usuárias), incluindo filtro/busca.
///
/// Antes cada tela (Perfil, Marketplace, Editar peça) instanciava o próprio
/// `ClosetService` e guardava a lista em `State` local — editar ou cadastrar
/// uma peça só refletia em outra tela se o resultado fosse passado à mão
/// pelo `Navigator.pop`. Centralizando aqui (mesmo padrão do `MapProvider`),
/// as duas listas ficam sempre consistentes e as telas passam a só cuidar
/// de UI.
class ClosetProvider extends ChangeNotifier {
  final ClosetService _closetService;

  ClosetProvider({ClosetService? closetService}) : _closetService = closetService ?? ClosetService();

  // --- Meu closet ---
  ClosetLoadState _myClosetState = ClosetLoadState.idle;
  List<ClosetItem> _myCloset = [];
  String? _myClosetError;

  ClosetLoadState get myClosetState => _myClosetState;
  List<ClosetItem> get myCloset => List.unmodifiable(_myCloset);
  String? get myClosetError => _myClosetError;

  Future<void> loadMyCloset() async {
    _myClosetState = ClosetLoadState.loading;
    notifyListeners();
    try {
      _myCloset = await _closetService.getMyCloset();
      _myClosetState = ClosetLoadState.loaded;
    } on ClosetException catch (e) {
      _myClosetError = e.message;
      _myClosetState = ClosetLoadState.error;
    } catch (_) {
      _myClosetError = 'Não foi possível carregar seu perfil.';
      _myClosetState = ClosetLoadState.error;
    }
    notifyListeners();
  }

  Future<ClosetItem> createItem({
    required String name,
    required String category,
    required double price,
    String? description,
  }) async {
    final created = await _closetService.createItem(
      name: name,
      category: category,
      price: price,
      description: description,
    );
    _myCloset = [created, ..._myCloset];
    notifyListeners();
    return created;
  }

  Future<ClosetItem> updateItem(ClosetItem item) async {
    final updated = await _closetService.updateItem(item);
    _myCloset = _myCloset.map((p) => p.id == updated.id ? updated : p).toList();
    notifyListeners();
    return updated;
  }

  Future<void> markAsSold(ClosetItem item) async {
    await _closetService.markAsSold(item.id);
    _myCloset = _myCloset.map((p) => p.id == item.id ? p.copyWith(status: ClosetItemStatus.sold) : p).toList();
    notifyListeners();
  }

  Future<void> deleteItem(ClosetItem item) async {
    await _closetService.deleteItem(item.id);
    _myCloset = _myCloset.where((p) => p.id != item.id).toList();
    notifyListeners();
  }

  // --- Marketplace ---
  ClosetLoadState _marketplaceState = ClosetLoadState.idle;
  List<ClosetItem> _marketplace = [];
  String? _marketplaceError;
  String? _buyingItemId;
  String _searchQuery = '';
  String? _categoryFilter;

  ClosetLoadState get marketplaceState => _marketplaceState;
  String? get marketplaceError => _marketplaceError;
  String? get buyingItemId => _buyingItemId;
  String get searchQuery => _searchQuery;
  String? get categoryFilter => _categoryFilter;

  /// Categorias presentes no marketplace carregado, pra montar os chips de
  /// filtro dinamicamente (sem lista fixa hardcoded).
  List<String> get marketplaceCategories {
    final categories = _marketplace.map((e) => e.category).where((c) => c.isNotEmpty).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Peças do marketplace já aplicando busca por nome + filtro de categoria
  /// (funcionalidade nova: antes a lista completa sempre aparecia inteira).
  List<ClosetItem> get filteredMarketplace {
    final query = _searchQuery.trim().toLowerCase();
    return _marketplace.where((item) {
      final matchesQuery = query.isEmpty || item.name.toLowerCase().contains(query);
      final matchesCategory = _categoryFilter == null || item.category == _categoryFilter;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  Future<void> loadMarketplace() async {
    _marketplaceState = ClosetLoadState.loading;
    notifyListeners();
    try {
      _marketplace = await _closetService.getMarketplace();
      _marketplaceState = ClosetLoadState.loaded;
    } on ClosetException catch (e) {
      _marketplaceError = e.message;
      _marketplaceState = ClosetLoadState.error;
    } catch (_) {
      _marketplaceError = 'Não foi possível carregar as peças.';
      _marketplaceState = ClosetLoadState.error;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    if (_categoryFilter == category) return;
    _categoryFilter = category;
    notifyListeners();
  }

  /// Compra uma peça do marketplace. Erros não são engolidos aqui (mesma
  /// filosofia do restante do app): a tela decide como mostrar a falha.
  Future<void> buyItem(ClosetItem item) async {
    _buyingItemId = item.id;
    notifyListeners();
    try {
      await _closetService.buyItem(item.id);
      _marketplace = _marketplace.where((e) => e.id != item.id).toList();
    } finally {
      _buyingItemId = null;
      notifyListeners();
    }
  }
}
