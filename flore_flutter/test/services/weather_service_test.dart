import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flore_flutter/services/weather_service.dart';

void main() {
  group('WeatherService.getWeather', () {
    test('retorna os dados reais quando a API responde 200', () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'api.open-meteo.com');
        return http.Response(
          '{"current":{"temperature_2m":18.5,"wind_speed_10m":12.0,"weather_code":3}}',
          200,
        );
      });

      final service = WeatherService(client: client);
      final result = await service.getWeather(-23.55, -46.63);

      expect(result.isFallback, isFalse);
      expect(result.data.temperature, 18.5);
      expect(result.data.condition, 'Parcialmente nublado');
      expect(result.data.isAdverse, isFalse);
    });

    test('marca como adversa quando o codigo de clima indica chuva/tempestade', () async {
      final client = MockClient((request) async {
        return http.Response(
          '{"current":{"temperature_2m":19.0,"wind_speed_10m":10.0,"weather_code":65}}',
          200,
        );
      });

      final service = WeatherService(client: client);
      final result = await service.getWeather(-23.55, -46.63);

      expect(result.data.isAdverse, isTrue);
    });

    test('cai no fallback e expõe o erro quando a API responde erro', () async {
      final client = MockClient((request) async {
        return http.Response('erro interno', 500);
      });

      final service = WeatherService(client: client);
      final result = await service.getWeather(-23.55, -46.63);

      expect(result.isFallback, isTrue);
      expect(result.errorMessage, isNotNull);
      expect(result.data.condition, 'Céu limpo');
    });

    test('cai no fallback e expõe o erro quando o client lança exceção (sem rede)', () async {
      final client = MockClient((request) async {
        throw Exception('Falha de conexão simulada');
      });

      final service = WeatherService(client: client);
      final result = await service.getWeather(-23.55, -46.63);

      expect(result.isFallback, isTrue);
      expect(result.errorMessage, isNotNull);
    });
  });
}
