import 'package:flutter/material.dart';
//import 'package:kindle/main.dart';
import 'package:kindle/screens/home_screen.dart';
//import 'package:kindle/screens/web3_login_screen.dart';
//import 'src/features/home/home_screen.dart';
import 'src/routes/app_routes.dart';

class Kindle extends StatelessWidget {
  const Kindle({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web3 GoFundMe',
      theme: ThemeData.light(), // or dark theme
      initialRoute: '/',

      routes: {
        ...appRoutes,
        //'/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        //'/create-post': (context) => const CreatePostScreen(),
        //'/web3-login': (context) => const Web3LoginScreen(),
        //'/post-detail': (context) => PostDetailScreen(post: selectedPost),
      }, // Defined in app_routes.dart
    );
  }
}
