// lib/screens/map_screen.dart
//
// Tela principal de Mapas e Geolocalização do Florê.
// Exibe no mapa: localização do usuário, centro de armazenamento,
// entregas em andamento e parceiros logísticos.
// Integra dados de clima (Open-Meteo) para contexto de entrega.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../models/delivery_model.dart';
import '../widgets/weather_card.dart';
import '../widgets/order_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  // Cores do Florê
  static const Color _primary = Color(0xFF5C7A5C);    // verde Florê
  static const Color _accent = Color(0xFFE8A87C);     // laranja Florê
  static const Color _background = Color(0xFFF5F0E8); // bege Florê

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().loadMapData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(),
      body: Consumer<MapProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return _buildLoading();
          if (provider.errorMessage != null) return _buildError(provider);
          return _buildContent(provider);
        },
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      title: const Row(
        children: [
          Icon(Icons.local_shipping_outlined, size: 20),
          SizedBox(width: 8),
          Text(
            'Rastreamento',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
        ],
      ),
      actions: [
        Consumer<MapProvider>(
          builder: (_, provider, __) => IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading ? null : provider.loadMapData,
          ),
        ),
      ],
    );
  }

  // ─── Corpo principal ──────────────────────────────────────────────────────

  Widget _buildContent(MapProvider provider) {
    return Column(
      children: [
        // Card de clima
        if (provider.weather != null)
          WeatherCard(weather: provider.weather!),

        // Mapa ocupa a maior parte da tela
        Expanded(
          flex: 5,
          child: _buildMap(provider),
        ),

        // Legenda de marcadores
        _buildLegend(),

        // Lista de pedidos ativos
        if (provider.activeOrders.isNotEmpty)
          Expanded(
            flex: 3,
            child: _buildOrdersList(provider),
          ),
      ],
    );
  }

  // ─── Google Maps ──────────────────────────────────────────────────────────

  Widget _buildMap(MapProvider provider) {
    // Centro padrão: São Paulo
    final initialTarget = provider.userPosition != null
        ? LatLng(
            provider.userPosition!.latitude,
            provider.userPosition!.longitude,
          )
        : const LatLng(-23.5505, -46.6333);

    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: 13.0,
      ),
      markers: provider.markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
      compassEnabled: true,
    );
  }

  // ─── Legenda ──────────────────────────────────────────────────────────────

  Widget _buildLegend() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(color: Colors.blue, label: 'Você'),
          _legendItem(color: Colors.green, label: 'Centro Florê'),
          _legendItem(color: Colors.orange, label: 'Entrega'),
          _legendItem(color: Colors.purple, label: 'Parceiro'),
        ],
      ),
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      children: [
        Icon(Icons.location_pin, color: color, size: 18),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  // ─── Lista de pedidos ─────────────────────────────────────────────────────

  Widget _buildOrdersList(MapProvider provider) {
    return Container(
      color: _background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Pedidos em andamento',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: provider.activeOrders.length,
              itemBuilder: (_, i) => OrderCard(
                order: provider.activeOrders[i],
                onTap: () => _focusOnDelivery(provider, provider.activeOrders[i]),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _focusOnDelivery(MapProvider provider, DeliveryOrder order) {
    // Encontra o ponto correspondente ao pedido no mapa
    final point = provider.mapPoints.firstWhere(
      (p) => p.type == 'delivery',
      orElse: () => provider.mapPoints.first,
    );

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(point.latitude, point.longitude),
          zoom: 15,
        ),
      ),
    );

    provider.selectOrder(order);
    _showOrderBottomSheet(order);
  }

  void _showOrderBottomSheet(DeliveryOrder order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OrderDetailSheet(order: order),
    );
  }

  // ─── Estados de UI ────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primary),
          const SizedBox(height: 16),
          Text(
            'Carregando mapa...',
            style: TextStyle(color: _primary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError(MapProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(provider.errorMessage!, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primary),
            onPressed: provider.loadMapData,
            child: const Text('Tentar novamente',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Sheet de detalhe do pedido ────────────────────────────────────────

class _OrderDetailSheet extends StatelessWidget {
  final DeliveryOrder order;

  const _OrderDetailSheet({required this.order});

  static const Color _primary = Color(0xFF5C7A5C);
  static const Color _accent = Color(0xFFE8A87C);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cabeçalho
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.itemName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Pedido ${order.orderId}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                      fontSize: 12,
                      color: _accent,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Barra de progresso
          Text(
            'Progresso da entrega',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: order.progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_primary),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Text(
            '${(order.progress * 100).toInt()}% concluído · ${order.estimatedDelivery}',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),

          // Timeline
          ...order.timeline.map((event) => _TimelineItem(event: event)),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final DeliveryEvent event;

  const _TimelineItem({required this.event});

  static const Color _primary = Color(0xFF5C7A5C);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            event.completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: event.completed ? _primary : Colors.grey[400],
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: event.completed ? Colors.black87 : Colors.grey[500],
                  ),
                ),
                if (event.description.isNotEmpty)
                  Text(
                    event.description,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          Text(
            event.time,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
