import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flore_flutter/services/weather_service.dart';
import 'package:flore_flutter/widgets/weather_card.dart';

void main() {
  testWidgets('renderiza condicao, temperatura e vento em clima favoravel', (tester) async {
    final weather = WeatherData(
      temperature: 22.4,
      windSpeed: 15,
      weatherCode: 0,
      condition: 'Céu limpo',
      isAdverse: false,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: WeatherCard(weather: weather)),
    ));

    expect(find.text('Céu limpo'), findsOneWidget);
    expect(find.text('22.4°C · Vento 15 km/h'), findsOneWidget);
    expect(find.text('Favorável'), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
  });

  testWidgets('mostra alerta quando o clima e adverso', (tester) async {
    final weather = WeatherData(
      temperature: 19,
      windSpeed: 60,
      weatherCode: 65,
      condition: 'Chuva',
      isAdverse: true,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: WeatherCard(weather: weather)),
    ));

    expect(find.text('Alerta'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });
}
