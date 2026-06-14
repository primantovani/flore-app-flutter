import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weather;
  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final isAdverse = weather.isAdverse;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isAdverse ? const Color(0xFFd4541a) : const Color(0xFF2a7d70),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isAdverse ? Icons.warning_amber_rounded : Icons.wb_sunny_outlined, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weather.condition, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${weather.temperature.toStringAsFixed(1)}°C · Vento ${weather.windSpeed.toStringAsFixed(0)} km/h',
                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(50)),
            child: Text(isAdverse ? 'Alerta' : 'Favorável',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
