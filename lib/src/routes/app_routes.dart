import 'package:flutter/material.dart';
import 'package:kindle/screens/home_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => HomeScreen(),
  //'/auth': (context) => AuthScreen(),
  //'/donation': (context) => DonationScreen(),
};
