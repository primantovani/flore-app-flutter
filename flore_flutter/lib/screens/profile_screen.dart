import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final _pecas = const [
    {'nome': 'Vestido Floral Midi', 'categoria': 'Vestidos', 'status': 'À venda', 'valor': 'R\$ 120'},
    {'nome': 'Calça Wide Leg Preta', 'categoria': 'Calças', 'status': 'Vendido', 'valor': 'R\$ 85'},
    {'nome': 'Blazer Oversized Bege', 'categoria': 'Casacos', 'status': 'À venda', 'valor': 'R\$ 160'},
    {'nome': 'Camiseta Estampada', 'categoria': 'Camisetas', 'status': 'À venda', 'valor': 'R\$ 45'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf7f5f2),
      appBar: AppBar(
        title: const Text('Meu Perfil', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {},
              child: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildStats(),
            _buildCloset(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2a7d70),
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
                  color: const Color(0xFF1a5c52),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                ),
                child: const Center(
                  child: Text('UF', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: const Color(0xFFd4541a), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Usuária Florê', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('usuario@flore.com.br', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFd4541a), borderRadius: BorderRadius.circular(50)),
            child: const Text('MODA CIRCULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _StatCard(value: '4', label: 'Peças\nno closet'),
          const SizedBox(width: 10),
          _StatCard(value: '1', label: 'Peças\nvendidas'),
          const SizedBox(width: 10),
          _StatCard(value: '3', label: 'Pedidos\nativos'),
        ],
      ),
    );
  }

  Widget _buildCloset(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Meu Closet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1a5c52))),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF2a7d70), borderRadius: BorderRadius.circular(50)),
                  child: const Text('+ Adicionar peça', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._pecas.map((peca) => _PecaCard(peca: peca)),
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
            title: const Text('Sair da conta', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1a5c52))),
            content: const Text('Tem certeza que deseja sair?', style: TextStyle(color: Color(0xFF6b6b6b))),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Color(0xFF6b6b6b)))),
              TextButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
                child: const Text('Sair', style: TextStyle(color: Color(0xFFd4541a), fontWeight: FontWeight.w700)),
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
          border: Border.all(color: const Color(0xFFe0e0e0)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xFF6b6b6b), size: 18),
            SizedBox(width: 8),
            Text('Sair da conta', style: TextStyle(color: Color(0xFF6b6b6b), fontWeight: FontWeight.w600, fontSize: 14)),
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
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1a5c52))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6b6b6b)), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _PecaCard extends StatelessWidget {
  final Map<String, String> peca;
  const _PecaCard({required this.peca});

  Color _statusColor() => peca['status'] == 'Vendido' ? const Color(0xFF2a7d70) : const Color(0xFFd4541a);

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
          decoration: BoxDecoration(color: const Color(0xFFe8f4f1), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.checkroom_outlined, color: Color(0xFF2a7d70), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(peca['nome']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1a5c52))),
            Text(peca['categoria']!, style: const TextStyle(fontSize: 11, color: Color(0xFF6b6b6b))),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(peca['valor']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1e1e1e))),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: _statusColor().withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
            child: Text(peca['status']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor())),
          ),
        ]),
      ]),
    );
  }
}
