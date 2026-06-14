import 'package:flutter_test/flutter_test.dart';
import 'package:flore_flutter/main.dart';
import 'package:provider/provider.dart';
import 'package:flore_flutter/providers/map_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MapProvider(),
        child: const FloreApp(),
      ),
    );
    expect(find.text('Florê App'), findsAny);
  });
}
