import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final String condition;
  final bool isAdverse;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.condition,
    required this.isAdverse,
  });
}

class WeatherService {
  Future<WeatherData> getWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,wind_speed_10m,weather_code',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'];
        final temp = (current['temperature_2m'] ?? 20).toDouble();
        final wind = (current['wind_speed_10m'] ?? 0).toDouble();
        final code = (current['weather_code'] ?? 0) as int;
        return WeatherData(
          temperature: temp,
          windSpeed: wind,
          weatherCode: code,
          condition: _getCondition(code),
          isAdverse: code >= 60 || wind > 50,
        );
      }
    } catch (_) {}
    return WeatherData(
      temperature: 22,
      windSpeed: 15,
      weatherCode: 0,
      condition: 'Céu limpo',
      isAdverse: false,
    );
  }

  String _getCondition(int code) {
    if (code == 0) return 'Céu limpo';
    if (code <= 3) return 'Parcialmente nublado';
    if (code <= 49) return 'Nevoeiro';
    if (code <= 59) return 'Garoa';
    if (code <= 67) return 'Chuva';
    if (code <= 77) return 'Neve';
    if (code <= 82) return 'Pancadas de chuva';
    return 'Tempestade';
  }
}
