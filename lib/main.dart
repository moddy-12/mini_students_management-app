import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UIUX App',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}