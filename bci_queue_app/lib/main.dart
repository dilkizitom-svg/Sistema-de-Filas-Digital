import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/identificacao_screen.dart';


final FlutterLocalNotificationsPlugin notificacoes = FlutterLocalNotificationsPlugin();

Future<void> inicializarNotificacoes() async {
  final android = AndroidInitializationSettings('@mipmap/ic_launcher');
  final settings = InitializationSettings(android: android);
  await notificacoes.initialize(
    settings: settings,
    onDidReceiveNotificationResponse: (details) {},
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inicializarNotificacoes();
  runApp(const BCIQueueApp());
}

class BCIQueueApp extends StatelessWidget {
  const BCIQueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BCI SmartFila',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE8001D),
          surface: Color(0xFF1A1A1A),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8001D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
      home: const IdentificacaoScreen(),
    );
  }
}