import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/delivery_order.dart';
import '../models/delivery_point.dart';
import '../services/weather_service.dart';
import '../services/delivery_service.dart';

enum LocationPermissionStatus { unknown, granted, denied, deniedForever, serviceDisabled }

class MapProvider extends ChangeNotifier {
  double userLat = -23.5505;
  double userLon = -46.6333;
  bool isLoading = true;
  bool hasError = false;

  LocationPermissionStatus locationStatus = LocationPermissionStatus.unknown;

  WeatherData? weather;
  List<DeliveryOrder> orders = [];
  List<DeliveryPoint> mapPoints = [];

  /// Mensagens de fallback (Melhoria D): preenchidas quando algum desses
  /// dados veio do mock por falha real na API, não um erro qualquer engolido.
  String? weatherFallbackMessage;
  String? ordersFallbackMessage;
  String? mapPointsFallbackMessage;

  final _weatherService = WeatherService();
  final _deliveryService = DeliveryService();

  Future<void> init() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    await _getUserLocation();
    await Future.wait([
      _loadWeather(),
      _loadOrders(),
      _loadMapPoints(),
    ]);

    hasError = weatherFallbackMessage != null ||
        ordersFallbackMessage != null ||
        mapPointsFallbackMessage != null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> _getUserLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('[LOCATION] serviceEnabled=$serviceEnabled');
      if (!serviceEnabled) {
        locationStatus = LocationPermissionStatus.serviceDisabled;
        return;
      }

      var permission = await Geolocator.checkPermission();
      debugPrint('[LOCATION] checkPermission=$permission');
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('[LOCATION] requestPermission=$permission');
      }
      if (permission == LocationPermission.denied) {
        locationStatus = LocationPermissionStatus.denied;
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        locationStatus = LocationPermissionStatus.deniedForever;
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      debugPrint('[LOCATION] posicao obtida: ${pos.latitude}, ${pos.longitude}');
      userLat = pos.latitude;
      userLon = pos.longitude;
      locationStatus = LocationPermissionStatus.granted;
    } catch (e) {
      debugPrint('[LOCATION] ERRO: $e');
      locationStatus = LocationPermissionStatus.denied;
    }
  }

  Future<void> retryLocation() async {
    debugPrint('[LOCATION] retryLocation chamado');
    await _getUserLocation();
    notifyListeners();
    debugPrint('[LOCATION] retryLocation terminou, status=$locationStatus');
  }

  Future<void> _loadWeather() async {
    final result = await _weatherService.getWeather(userLat, userLon);
    weather = result.data;
    weatherFallbackMessage = result.isFallback ? result.errorMessage : null;
  }

  Future<void> _loadOrders() async {
    final result = await _deliveryService.getOrders();
    orders = result.data;
    ordersFallbackMessage = result.isFallback ? result.errorMessage : null;
  }

  Future<void> _loadMapPoints() async {
    final result = await _deliveryService.getMapPoints();
    mapPoints = result.data;
    mapPointsFallbackMessage = result.isFallback ? result.errorMessage : null;
  }
}
