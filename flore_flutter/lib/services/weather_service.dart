import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

/// Resultado da consulta de clima, com o fallback exposto (Melhoria D).
class WeatherResult {
  final WeatherData data;
  final bool isFallback;
  final String? errorMessage;

  const WeatherResult({required this.data, this.isFallback = false, this.errorMessage});
}

class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherResult> getWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,wind_speed_10m,weather_code',
      );
      final response = await _client.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'];
        final temp = (current['temperature_2m'] ?? 20).toDouble();
        final wind = (current['wind_speed_10m'] ?? 0).toDouble();
        final code = (current['weather_code'] ?? 0) as int;
        return WeatherResult(
          data: WeatherData(
            temperature: temp,
            windSpeed: wind,
            weatherCode: code,
            condition: _getCondition(code),
            isAdverse: code >= 60 || wind > 50,
          ),
        );
      }
      return _fallback('Não foi possível carregar o clima (erro ${response.statusCode}).');
    } on TimeoutException {
      return _fallback('Tempo de conexão esgotado.');
    } on SocketException {
      return _fallback('Sem conexão com o servidor de clima.');
    } catch (_) {
      return _fallback('Não foi possível carregar o clima.');
    }
  }

  WeatherResult _fallback(String message) {
    return WeatherResult(
      data: WeatherData(
        temperature: 22,
        windSpeed: 15,
        weatherCode: 0,
        condition: 'Céu limpo',
        isAdverse: false,
      ),
      isFallback: true,
      errorMessage: '$message Mostrando dados de exemplo.',
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
