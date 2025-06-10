import 'package:flutter/material.dart';
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
      routes: appRoutes, // Defined in app_routes.dart
    );
  }
}
