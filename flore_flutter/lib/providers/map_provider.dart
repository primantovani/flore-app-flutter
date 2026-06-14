import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/delivery_order.dart';
import '../models/delivery_point.dart';
import '../services/weather_service.dart';
import '../services/delivery_service.dart';

class MapProvider extends ChangeNotifier {
  double userLat = -23.5505;
  double userLon = -46.6333;
  bool isLoading = true;
  bool hasError = false;

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
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      userLat = pos.latitude;
      userLon = pos.longitude;
    } catch (_) {}
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
