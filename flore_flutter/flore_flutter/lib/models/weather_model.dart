// lib/models/weather_model.dart

class WeatherData {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final String description;
  final bool isGoodForDelivery;
  final String deliveryImpact;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.description,
    required this.isGoodForDelivery,
    required this.deliveryImpact,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final temp = current['temperature_2m'].toDouble();
    final wind = current['wind_speed_10m'].toDouble();
    final code = current['weather_code'] as int;

    final desc = _descriptionFromCode(code);
    final goodForDelivery = code < 60 && wind < 50;
    final impact = goodForDelivery
        ? 'Condições favoráveis para entrega'
        : 'Possível impacto nas entregas — prazo pode ser ajustado';

    return WeatherData(
      temperature: temp,
      windSpeed: wind,
      weatherCode: code,
      description: desc,
      isGoodForDelivery: goodForDelivery,
      deliveryImpact: impact,
    );
  }

  static String _descriptionFromCode(int code) {
    if (code == 0) return 'Céu limpo';
    if (code <= 3) return 'Parcialmente nublado';
    if (code <= 49) return 'Névoa';
    if (code <= 59) return 'Garoa';
    if (code <= 69) return 'Chuva';
    if (code <= 79) return 'Neve';
    if (code <= 82) return 'Pancadas de chuva';
    if (code <= 99) return 'Tempestade';
    return 'Condição desconhecida';
  }
}
