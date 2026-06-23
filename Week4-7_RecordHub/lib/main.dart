import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
<<<<<<< HEAD

void main() {
  runApp(const RecordHubApp());
}

class RecordHubApp extends StatelessWidget {
  const RecordHubApp({super.key});
=======
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
>>>>>>> 96f35c00641fb6702b388356599d68671c602307

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      title: 'RecordHub',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        typography: Typography.material2021(),
      ),
=======
      title: 'UIUX App',
      theme: AppTheme.lightTheme,
>>>>>>> 96f35c00641fb6702b388356599d68671c602307
      home: const LoginScreen(),
    );
  }
}