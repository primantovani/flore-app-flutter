import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flore_flutter/main.dart';
import 'package:flore_flutter/providers/map_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App smoke test: sem sessão salva, cai na tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MapProvider(),
        child: const FloreApp(),
      ),
    );

    // SplashScreen resolve a sessão de forma assíncrona antes de navegar.
    await tester.pumpAndSettle();

    expect(find.text('Florê'), findsWidgets);
    expect(find.text('Bem-vinda de volta'), findsOneWidget);
  });
}
