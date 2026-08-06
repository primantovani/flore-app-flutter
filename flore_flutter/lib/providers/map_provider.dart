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
    weather = await _weatherService.getWeather(userLat, userLon);
  }

  Future<void> _loadOrders() async {
    orders = await _deliveryService.getOrders();
  }

  Future<void> _loadMapPoints() async {
    mapPoints = await _deliveryService.getMapPoints();
  }
}
