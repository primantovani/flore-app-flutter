import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/map_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().init();
    });
  }

  Color _pointColor(String type) {
    switch (type) {
      case 'warehouse': return const Color(0xFF2a7d70);
      case 'delivery':  return const Color(0xFFd4541a);
      case 'partner':   return const Color(0xFF6b6b6b);
      default:          return const Color(0xFF3d9e8f);
    }
  }

  IconData _pointIcon(String type) {
    switch (type) {
      case 'warehouse': return Icons.warehouse_outlined;
      case 'delivery':  return Icons.local_shipping_outlined;
      case 'partner':   return Icons.store_outlined;
      default:          return Icons.location_on_outlined;
    }
  }

  Future<void> _handleRetry(BuildContext context, MapProvider provider) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verificando localizacao...'), duration: Duration(seconds: 1)),
    );
    await provider.retryLocation();
    if (!context.mounted) return;
    final status = provider.locationStatus;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Resultado: $status'), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf7f5f2),
      appBar: AppBar(title: const Text('Rastreamento', style: TextStyle(fontWeight: FontWeight.w700))),
      body: Consumer<MapProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF2a7d70)),
                SizedBox(height: 16),
                Text('Carregando...', style: TextStyle(color: Color(0xFF6b6b6b))),
              ],
            ));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.locationStatus != LocationPermissionStatus.granted &&
                    provider.locationStatus != LocationPermissionStatus.unknown) ...[
                  _buildLocationBanner(context, provider),
                  const SizedBox(height: 16),
                ],
                if (provider.weather != null) ...[
                  WeatherCard(weather: provider.weather!),
                  const SizedBox(height: 20),
                ],
                const Text('Pontos de entrega', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1a5c52))),
                const SizedBox(height: 12),
                _buildMapCard(context, provider),
                const SizedBox(height: 24),
                const Text('Pedidos ativos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1a5c52))),
                const SizedBox(height: 12),
                ...provider.orders
                    .where((o) => o.status != 'Entregue')
                    .map((order) => OrderCard(
                          order: order,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))),
                        )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationBanner(BuildContext context, MapProvider provider) {
    String message;
    String actionLabel;
    VoidCallback action;

    switch (provider.locationStatus) {
      case LocationPermissionStatus.serviceDisabled:
        message = 'O GPS do seu celular esta desligado. Ative a localizacao para ver pontos proximos a voce.';
        actionLabel = 'Abrir configuracoes de GPS';
        action = () => Geolocator.openLocationSettings();
        break;
      case LocationPermissionStatus.deniedForever:
        message = 'A permissao de localizacao foi negada permanentemente. Ative manualmente nas configuracoes do app.';
        actionLabel = 'Abrir configuracoes do app';
        action = () => Geolocator.openAppSettings();
        break;
      default:
        message = 'Localizacao nao concedida. Usando Sao Paulo como referencia padrao.';
        actionLabel = 'Tentar novamente';
        action = () => _handleRetry(context, provider);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFd4541a).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_off_outlined, color: Color(0xFFd4541a), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Localizacao indisponivel', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFd4541a))),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFF6b6b6b))),
          const SizedBox(height: 10),
          TextButton(
            onPressed: action,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(actionLabel, style: const TextStyle(color: Color(0xFF2a7d70), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard(BuildContext context, MapProvider provider) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFe8f4f1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3d9e8f).withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map_outlined, size: 40, color: Color(0xFF2a7d70)),
                const SizedBox(height: 6),
                const Text('Sao Paulo, SP', style: TextStyle(color: Color(0xFF1a5c52), fontWeight: FontWeight.w700, fontSize: 15)),
                Text('${provider.mapPoints.length} pontos ativos', style: const TextStyle(color: Color(0xFF6b6b6b), fontSize: 12)),
              ],
            ),
          ),
          ...provider.mapPoints.asMap().entries.map((entry) {
            final point = entry.value;
            final positions = [
              const Offset(0.5, 0.38),
              const Offset(0.22, 0.62),
              const Offset(0.72, 0.65),
              const Offset(0.3, 0.28),
              const Offset(0.74, 0.3),
            ];
            final pos = positions[entry.key % positions.length];
            return Positioned(
              left: MediaQuery.of(context).size.width * pos.dx - 60,
              top: 300 * pos.dy - 24,
              child: Column(
                children: [
                  Icon(_pointIcon(point.type), color: _pointColor(point.type), size: 26),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)],
                    ),
                    child: Text(point.label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF1a5c52))),
                  ),
                ],
              ),
            );
          }),
          Positioned(
            bottom: 10,
            left: 12,
            child: Row(children: [
              _Legend(color: const Color(0xFF2a7d70), label: 'Armazem'),
              const SizedBox(width: 10),
              _Legend(color: const Color(0xFFd4541a), label: 'Entrega'),
              const SizedBox(width: 10),
              _Legend(color: const Color(0xFF6b6b6b), label: 'Parceiro'),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF1a5c52))),
    ]);
  }
}
