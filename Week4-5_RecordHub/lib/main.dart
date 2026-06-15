import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const RecordHubApp());
}

class RecordHubApp extends StatelessWidget {
  const RecordHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RecordHub',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        typography: Typography.material2021(),
      ),
      home: const LoginScreen(),
    );
  }
}