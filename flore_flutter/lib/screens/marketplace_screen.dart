import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/closet_item.dart';
import '../providers/closet_provider.dart';
import '../services/closet_service.dart';
import '../theme/app_colors.dart';

/// Fluxo de compra (item 2): navega pelas peças à venda de outras usuárias
/// e permite comprar. Antes esse fluxo não existia — o app só mostrava o
/// closet da própria usuária.
///
/// Agora com busca por nome + filtro por categoria (funcionalidade nova),
/// usando o [ClosetProvider] compartilhado em vez de estado local.
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ClosetProvider>().loadMarketplace();
    });
  }

  Future<void> _confirmAndBuy(BuildContext context, ClosetItem item) async {
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
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<ClosetProvider>().buyItem(item);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compra de "${item.name}" confirmada!'), backgroundColor: AppColors.teal, behavior: SnackBarBehavior.floating),
      );
    } on ClosetException catch (e) {
      _showError(context, e.message);
    } catch (_) {
      _showError(context, 'Não foi possível concluir a compra.');
    }
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.orange, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Marketplace', style: TextStyle(fontWeight: FontWeight.w700))),
      body: SafeArea(
        child: Consumer<ClosetProvider>(
          builder: (context, closet, _) => Column(
            children: [
              _buildSearchAndFilters(context, closet),
              Expanded(child: _buildBody(context, closet)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, ClosetProvider closet) {
    final categories = closet.marketplaceCategories;
    if (closet.marketplaceState != ClosetLoadState.loaded) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) => context.read<ClosetProvider>().setSearchQuery(value),
            decoration: InputDecoration(
              hintText: 'Buscar peça pelo nome',
              hintStyle: const TextStyle(color: AppColors.gray, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppColors.gray, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
            ),
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    label: 'Todas',
                    selected: closet.categoryFilter == null,
                    onTap: () => context.read<ClosetProvider>().setCategoryFilter(null),
                  ),
                  ...categories.map((category) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _CategoryChip(
                          label: category,
                          selected: closet.categoryFilter == category,
                          onTap: () => context.read<ClosetProvider>().setCategoryFilter(category),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ClosetProvider closet) {
    switch (closet.marketplaceState) {
      case ClosetLoadState.idle:
      case ClosetLoadState.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.teal));
      case ClosetLoadState.error:
        return _buildMessage(
          icon: Icons.wifi_off_outlined,
          title: 'Algo deu errado',
          subtitle: closet.marketplaceError ?? 'Tente novamente.',
          actionLabel: 'Tentar novamente',
          onAction: () => context.read<ClosetProvider>().loadMarketplace(),
        );
      case ClosetLoadState.loaded:
        final items = closet.filteredMarketplace;
        if (items.isEmpty) {
          final hasActiveFilter = closet.searchQuery.isNotEmpty || closet.categoryFilter != null;
          return _buildMessage(
            icon: Icons.checkroom_outlined,
            title: hasActiveFilter ? 'Nenhuma peça encontrada' : 'Nenhuma peça disponível',
            subtitle: hasActiveFilter
                ? 'Tente ajustar a busca ou o filtro de categoria.'
                : 'Ainda não há peças à venda de outras usuárias.',
          );
        }
        return RefreshIndicator(
          onRefresh: () => context.read<ClosetProvider>().loadMarketplace(),
          color: AppColors.teal,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            itemCount: items.length,
            itemBuilder: (_, i) => _MarketplaceItemCard(
              item: items[i],
              isBuying: closet.buyingItemId == items[i].id,
              onBuy: () => _confirmAndBuy(context, items[i]),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: selected ? AppColors.teal : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.gray),
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
