import 'package:flutter/material.dart';
import '../models/closet_item.dart';
import '../services/closet_service.dart';
import '../theme/app_colors.dart';

/// Fluxo de compra (item 2): navega pelas peças à venda de outras usuárias
/// e permite comprar. Antes esse fluxo não existia — o app só mostrava o
/// closet da própria usuária.
class MarketplaceScreen extends StatefulWidget {
  final ClosetService? closetService;

  const MarketplaceScreen({super.key, this.closetService});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

enum _LoadState { loading, loaded, error }

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late final _closetService = widget.closetService ?? ClosetService();
  _LoadState _state = _LoadState.loading;
  List<ClosetItem> _items = [];
  String? _errorMessage;
  String? _buyingItemId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = _LoadState.loading);
    try {
      final items = await _closetService.getMarketplace();
      if (!mounted) return;
      setState(() {
        _items = items;
        _state = _LoadState.loaded;
      });
    } on ClosetException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _state = _LoadState.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Não foi possível carregar as peças.';
        _state = _LoadState.error;
      });
    }
  }

  Future<void> _confirmAndBuy(ClosetItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Comprar peça', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.tealDark)),
        content: Text('Confirmar compra de "${item.name}" por R\$ ${item.price.toStringAsFixed(2)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: AppColors.gray))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Comprar', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _buyingItemId = item.id);
    try {
      await _closetService.buyItem(item.id);
      if (!mounted) return;
      setState(() => _items = _items.where((e) => e.id != item.id).toList());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compra de "${item.name}" confirmada!'), backgroundColor: AppColors.teal, behavior: SnackBarBehavior.floating),
      );
    } on ClosetException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Não foi possível concluir a compra.');
    } finally {
      if (mounted) setState(() => _buyingItemId = null);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.orange, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Marketplace', style: TextStyle(fontWeight: FontWeight.w700))),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _LoadState.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.teal));
      case _LoadState.error:
        return _buildMessage(
          icon: Icons.wifi_off_outlined,
          title: 'Algo deu errado',
          subtitle: _errorMessage ?? 'Tente novamente.',
          actionLabel: 'Tentar novamente',
          onAction: _load,
        );
      case _LoadState.loaded:
        if (_items.isEmpty) {
          return _buildMessage(
            icon: Icons.checkroom_outlined,
            title: 'Nenhuma peça disponível',
            subtitle: 'Ainda não há peças à venda de outras usuárias.',
          );
        }
        return RefreshIndicator(
          onRefresh: _load,
          color: AppColors.teal,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _items.length,
            itemBuilder: (_, i) => _MarketplaceItemCard(
              item: _items[i],
              isBuying: _buyingItemId == _items[i].id,
              onBuy: () => _confirmAndBuy(_items[i]),
            ),
          ),
        );
    }
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.gray),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.gray)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(50)),
                  child: Text(actionLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MarketplaceItemCard extends StatelessWidget {
  final ClosetItem item;
  final bool isBuying;
  final VoidCallback onBuy;

  const _MarketplaceItemCard({required this.item, required this.isBuying, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16)],
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: AppColors.tealSurface, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.checkroom_outlined, color: AppColors.teal, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.tealDark)),
            Text('${item.category} · vendido por ${item.ownerName}', style: const TextStyle(fontSize: 11, color: AppColors.gray)),
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('R\$ ${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.dark)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: isBuying ? null : onBuy,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(50)),
              child: isBuying
                  ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Comprar', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ]),
    );
  }
}
