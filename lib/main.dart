import 'package:flutter/material.dart';
import 'package:kindle/screens/home_screen.dart';
import 'package:kindle/src/features/auth/login_screen.dart';
import 'package:kindle/src/features/auth/register_screen.dart';
import 'package:kindle/src/features/fundraiser/create_fundraiser_screen.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://jszaldpujukgyrufbkan.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpzemFsZHB1anVrZ3lydWZia2FuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk1NzQzMzgsImV4cCI6MjA2NTE1MDMzOH0.4fH0JqZtT7ArlRCrhV2aMfeQLOar2ag3xaabR1s1gBU',
  );
  runApp(const KindleApp());
}

class KindleApp extends StatelessWidget {
  const KindleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web3 GoFundMe',
      theme: ThemeData(primarySwatch: Colors.indigo),
      routes: {
        '/': (context) => const AuthGate(),
        '/home': (context) => const HomeScreen(),
        '/create-post': (context) => const CreateFundraiserScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
