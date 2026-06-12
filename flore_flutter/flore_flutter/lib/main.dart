// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/map_provider.dart';
import 'screens/map_screen.dart';
import 'screens/notification_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  // Substitua pelas opções do seu google-services.json
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'SUA_API_KEY',
        appId: 'SEU_APP_ID',
        messagingSenderId: 'SEU_SENDER_ID',
        projectId: 'flore-app',
      ),
    );
  } catch (e) {
    debugPrint('Firebase não configurado: $e');
  }

  runApp(const FloreApp());
}

class FloreApp extends StatelessWidget {
  const FloreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: MaterialApp(
        title: 'Florê',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5C7A5C),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        // Rotas do app
        initialRoute: '/map',
        routes: {
          '/map': (_) => const MapScreen(),
          '/notifications': (_) => const NotificationScreen(),
        },
      ),
    );
  }
}
