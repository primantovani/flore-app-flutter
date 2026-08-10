import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flore_flutter/models/delivery_order.dart';
import 'package:flore_flutter/widgets/order_card.dart';

void main() {
  DeliveryOrder buildOrder({double progress = 0.65}) {
    return DeliveryOrder(
      id: '001',
      itemName: 'Vestido Azul com Flores',
      status: 'Em trânsito',
      origin: 'Armazém Florê - SP',
      destination: 'Rua das Flores, 42 - SP',
      estimatedDelivery: 'Hoje, até 18h',
      progress: progress,
      timeline: const [],
    );
  }

  testWidgets('renderiza nome, status, previsao e progresso do pedido', (tester) async {
    final order = buildOrder(progress: 0.65);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: OrderCard(order: order)),
    ));

    expect(find.text('Vestido Azul com Flores'), findsOneWidget);
    expect(find.text('Em trânsito'), findsOneWidget);
    expect(find.text('Hoje, até 18h'), findsOneWidget);
    expect(find.text('65% concluído'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('chama onTap quando o card e tocado', (tester) async {
    var tapped = false;
    final order = buildOrder();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: OrderCard(order: order, onTap: () => tapped = true)),
    ));

    await tester.tap(find.byType(OrderCard));
    expect(tapped, isTrue);
  });
}
