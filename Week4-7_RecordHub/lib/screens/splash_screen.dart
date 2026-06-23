import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../database/student_database.dart';
import 'registration_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () => setState(() => _visible = true));
    _loadStudentsAndNavigate();
  }

  Future<void> _loadStudentsAndNavigate() async {
    final rows = await StudentDatabase.getAllStudents();
    if (!mounted) return;
    RegistrationScreen.students = rows.map((r) => {
      'id': r['id'],
      'name': r['name'],
      'adm': r['admission'],
      'course': r['course'],
    }).toList();

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: _visible ? 1.0 : 0.85),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, v, child) {
            return Transform.scale(
              scale: v,
              child: Opacity(opacity: (_visible ? 1.0 : 0.0), child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [primary, Theme.of(context).colorScheme.primaryContainer]),
                  boxShadow: [BoxShadow(color: primary.withAlpha(51), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: const Center(child: Icon(Icons.school, size: 56, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              Text('Student UI App', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}