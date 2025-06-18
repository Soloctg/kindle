import 'package:flutter/material.dart';
import 'package:kindle/src/features/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    // Check current session and navigate accordingly
    final session = Supabase.instance.client.auth.currentSession;

    Future.microtask(() {
      if (session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });

    // Optional: Listen for auth state changes (not strictly needed on startup)
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash/loading while deciding
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
