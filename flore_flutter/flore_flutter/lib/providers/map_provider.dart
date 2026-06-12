// lib/providers/map_provider.dart
//
// Gerencia o estado da tela de mapa usando Provider.
// Centraliza: localização do usuário, pontos do mapa,
// pedidos ativos, clima e status de carregamento.

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/delivery_model.dart';
import '../models/weather_model.dart';
import '../services/delivery_service.dart';
import '../services/weather_service.dart';

class MapProvider extends ChangeNotifier {
  final DeliveryService _deliveryService = DeliveryService();
  final WeatherService _weatherService = WeatherService();

  // Estado
  bool isLoading = true;
  String? errorMessage;

  Position? userPosition;
  WeatherData? weather;
  List<DeliveryPoint> mapPoints = [];
  List<DeliveryOrder> activeOrders = [];
  Set<Marker> markers = {};
  DeliveryOrder? selectedOrder;

  /// Carrega todos os dados da tela de mapa
  Future<void> loadMapData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 1. Localização do usuário
      userPosition = await _getUserLocation();

      // 2. Dados em paralelo: clima + pontos + pedidos
      final results = await Future.wait([
        _weatherService.getCurrentWeather(
          latitude: userPosition?.latitude ?? -23.5505,
          longitude: userPosition?.longitude ?? -46.6333,
        ),
        _deliveryService.getMapPoints(),
        _deliveryService.getActiveOrders('user-001'),
      ]);

      weather = results[0] as WeatherData?;
      mapPoints = results[1] as List<DeliveryPoint>;
      activeOrders = results[2] as List<DeliveryOrder>;

      // 3. Monta marcadores do mapa
      _buildMarkers();
    } catch (e) {
      errorMessage = 'Não foi possível carregar os dados do mapa.';
    }

    isLoading = false;
    notifyListeners();
  }

  void selectOrder(DeliveryOrder order) {
    selectedOrder = order;
    notifyListeners();
  }

  void clearSelectedOrder() {
    selectedOrder = null;
    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<Position?> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  void _buildMarkers() {
    final Set<Marker> result = {};

    // Marcador do usuário
    if (userPosition != null) {
      result.add(Marker(
        markerId: const MarkerId('user'),
        position: LatLng(userPosition!.latitude, userPosition!.longitude),
        infoWindow: const InfoWindow(title: 'Você está aqui'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }

    // Marcadores dos pontos do mapa
    for (final point in mapPoints) {
      double hue;
      switch (point.type) {
        case 'warehouse':
          hue = BitmapDescriptor.hueGreen;
          break;
        case 'delivery':
          hue = BitmapDescriptor.hueOrange;
          break;
        case 'partner':
          hue = BitmapDescriptor.hueViolet;
          break;
        default:
          hue = BitmapDescriptor.hueRed;
      }

      result.add(Marker(
        markerId: MarkerId(point.id),
        position: LatLng(point.latitude, point.longitude),
        infoWindow: InfoWindow(
          title: point.label,
          snippet: point.estimatedTime != null
              ? '${point.status} · ${point.estimatedTime}'
              : point.status,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      ));
    }

    markers = result;
  }
}
