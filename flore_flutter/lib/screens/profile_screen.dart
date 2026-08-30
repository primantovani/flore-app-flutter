import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../models/closet_item.dart';
import '../providers/closet_provider.dart';
import '../services/auth_service.dart';
import '../services/closet_service.dart';
import '../theme/app_colors.dart';
import 'edit_closet_item_screen.dart';
import 'edit_profile_screen.dart';
import 'marketplace_screen.dart';

/// Perfil da usuária + CRUD real do closet (item 2). A lista de peças agora
/// vive no [ClosetProvider] (refatoração arquitetural): antes cada tela
/// guardava sua própria cópia local em `State`, e cadastrar/editar uma peça
/// só refletia aqui se o resultado voltasse pelo `Navigator.pop`. Com o
/// provider compartilhado, o closet e o marketplace ficam sempre
/// consistentes entre telas.
class ProfileScreen extends StatefulWidget {
  final AuthService? authService;

  const ProfileScreen({super.key, this.authService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

enum _UserLoadState { loading, loaded, error }

class _ProfileScreenState extends State<ProfileScreen> {
  late final _authService = widget.authService ?? AuthService();

  _UserLoadState _userState = _UserLoadState.loading;
  String? _userErrorMessage;
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ClosetProvider>().loadMyCloset();
    });
  }

  Future<void> _loadUser() async {
    setState(() => _userState = _UserLoadState.loading);
    try {
      final user = await _authService.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _user = user;
        _userState = _UserLoadState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userErrorMessage = 'Não foi possível carregar seu perfil.';
        _userState = _UserLoadState.error;
      });
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadUser(),
      context.read<ClosetProvider>().loadMyCloset(),
    ]);
  }

  Future<void> _openEditProfile() async {
    if (_user == null) return;
    final updated = await Navigator.push<AppUser>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user!)),
    );
    if (updated != null && mounted) setState(() => _user = updated);
  }

  Future<void> _openAddItem() async {
    await Navigator.push<ClosetItem>(
      context,
      MaterialPageRoute(builder: (_) => const EditClosetItemScreen()),
    );
  }

  Future<void> _openEditItem(ClosetItem item) async {
    await Navigator.push<ClosetItem>(
      context,
      MaterialPageRoute(builder: (_) => EditClosetItemScreen(existingItem: item)),
    );
  }

  Future<void> _markAsSold(ClosetItem item) async {
    try {
      await context.read<ClosetProvider>().markAsSold(item);
    } on ClosetException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Não foi possível marcar a peça como vendida.');
    }
  }

  Future<void> _deleteItem(ClosetItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover peça', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.tealDark)),
        content: Text('Remover "${item.name}" do seu closet?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: AppColors.gray))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remover', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context.read<ClosetProvider>().deleteItem(item);
    } on ClosetException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Não foi possível remover a peça.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.orange, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Meu Perfil', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _openEditProfile,
              child: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_userState == _UserLoadState.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.teal));
    }
    if (_userState == _UserLoadState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_outlined, size: 48, color: AppColors.gray),
              const SizedBox(height: 16),
              const Text('Algo deu errado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 8),
              Text(_userErrorMessage ?? 'Tente novamente.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.gray)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _refreshAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(50)),
                  child: const Text('Tentar novamente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      color: AppColors.teal,
      child: Consumer<ClosetProvider>(
        builder: (context, closet, _) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(),
                _buildStats(closet.myCloset),
                _buildMarketplaceEntry(context),
                _buildCloset(context, closet),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    final initials = _initialsFor(_user?.name);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.tealDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                ),
                child: Center(
                  child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppColors.orange, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(_user?.name.isNotEmpty == true ? _user!.name : 'Usuária Florê',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(_user?.email ?? 'usuario@flore.com.br', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(50)),
            child: const Text('MODA CIRCULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  String _initialsFor(String? name) {
    if (name == null || name.trim().isEmpty) return 'UF';
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  Widget _buildStats(List<ClosetItem> pecas) {
    final vendidas = pecas.where((p) => p.status == ClosetItemStatus.sold).length;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _StatCard(value: '${pecas.length}', label: 'Peças\nno closet'),
          const SizedBox(width: 10),
          _StatCard(value: '$vendidas', label: 'Peças\nvendidas'),
          const SizedBox(width: 10),
          const _StatCard(value: '0', label: 'Pedidos\nativos'),
        ],
      ),
    );
  }

  Widget _buildMarketplaceEntry(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen())),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.tealSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.tealLight.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.storefront_outlined, color: AppColors.teal, size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Comprar peças de outras usuárias', style: TextStyle(color: AppColors.tealDark, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              const Icon(Icons.chevron_right, color: AppColors.teal, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloset(BuildContext context, ClosetProvider closet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Meu Closet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.tealDark)),
              GestureDetector(
                onTap: _openAddItem,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(50)),
                  child: const Text('+ Adicionar peça', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (closet.myClosetState == ClosetLoadState.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
            )
          else if (closet.myClosetState == ClosetLoadState.error)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Text(closet.myClosetError ?? 'Não foi possível carregar seu perfil.',
                      textAlign: TextAlign.center, style: const TextStyle(color: AppColors.gray, fontSize: 13)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context.read<ClosetProvider>().loadMyCloset(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(50)),
                      child: const Text('Tentar novamente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            )
          else if (closet.myCloset.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Seu closet está vazio. Cadastre a primeira peça!', style: TextStyle(color: AppColors.gray, fontSize: 13)),
              ),
            )
          else
            ...closet.myCloset.map((peca) => _PecaCard(
                  peca: peca,
                  onEdit: () => _openEditItem(peca),
                  onMarkSold: peca.isAvailable ? () => _markAsSold(peca) : null,
                  onDelete: () => _deleteItem(peca),
                )),
          const SizedBox(height: 24),
          _buildLogoutButton(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Sair da conta', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.tealDark)),
            content: const Text('Tem certeza que deseja sair?', style: TextStyle(color: AppColors.gray)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: AppColors.gray))),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                child: const Text('Sair', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppColors.gray, size: 18),
            SizedBox(width: 8),
            Text('Sair da conta', style: TextStyle(color: AppColors.gray, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16)],
        ),
        child: Column(children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _PecaCard extends StatelessWidget {
  final ClosetItem peca;
  final VoidCallback onEdit;
  final VoidCallback? onMarkSold;
  final VoidCallback onDelete;

  const _PecaCard({required this.peca, required this.onEdit, required this.onMarkSold, required this.onDelete});

  Color _statusColor() => peca.isAvailable ? AppColors.orange : AppColors.teal;
  String _statusLabel() => peca.isAvailable ? 'À venda' : 'Vendido';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.tealSurface, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.checkroom_outlined, color: AppColors.teal, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(peca.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.tealDark)),
                Text(peca.category, style: const TextStyle(fontSize: 11, color: AppColors.gray)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('R\$ ${peca.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.dark)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: _statusColor().withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
                child: Text(_statusLabel(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor())),
              ),
            ]),
          ]),
          const SizedBox(height: 10),
          Row(
            children: [
              _ActionChip(label: 'Editar', icon: Icons.edit_outlined, onTap: onEdit),
              const SizedBox(width: 8),
              if (onMarkSold != null) _ActionChip(label: 'Marcar vendida', icon: Icons.sell_outlined, onTap: onMarkSold!),
              const Spacer(),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline, color: AppColors.gray, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: AppColors.gray),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
