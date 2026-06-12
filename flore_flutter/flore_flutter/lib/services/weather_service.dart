// lib/services/weather_service.dart
//
// Integração com Open-Meteo (https://open-meteo.com/)
// API gratuita, sem necessidade de chave de API.
// Retorna dados climáticos em tempo real usados para avaliar
// condições de entrega e exibir no painel logístico.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Busca clima atual para a latitude/longitude fornecida.
  /// Usado no mapa para indicar condições de entrega na região.
  Future<WeatherData?> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'temperature_2m,wind_speed_10m,weather_code',
        'timezone': 'America/Sao_Paulo',
        'forecast_days': '1',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data);
      }
    } catch (e) {
      // Retorna dado simulado em caso de falha de rede
      return _fallbackWeather();
    }

    return _fallbackWeather();
  }

  WeatherData _fallbackWeather() {
    return WeatherData(
      temperature: 22.0,
      windSpeed: 15.0,
      weatherCode: 1,
      description: 'Parcialmente nublado',
      isGoodForDelivery: true,
      deliveryImpact: 'Condições favoráveis para entrega',
    );
  }
}
