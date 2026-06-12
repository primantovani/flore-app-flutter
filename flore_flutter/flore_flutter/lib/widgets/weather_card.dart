// lib/widgets/weather_card.dart

import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weather;

  const WeatherCard({super.key, required this.weather});

  static const Color _primary = Color(0xFF5C7A5C);
  static const Color _accent = Color(0xFFE8A87C);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Temperatura e ícone
          Icon(_weatherIcon(weather.weatherCode),
              color: _primary, size: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather.temperature.toStringAsFixed(1)}°C · ${weather.description}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                'Vento: ${weather.windSpeed.toStringAsFixed(0)} km/h',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          const Spacer(),
          // Impacto na entrega
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: weather.isGoodForDelivery
                  ? _primary.withOpacity(0.1)
                  : _accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              weather.isGoodForDelivery ? '✓ Entrega ok' : '⚠ Atenção',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: weather.isGoodForDelivery ? _primary : _accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _weatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.cloud;
    if (code <= 59) return Icons.foggy;
    if (code <= 69) return Icons.umbrella;
    if (code <= 82) return Icons.grain;
    return Icons.thunderstorm;
  }
}
