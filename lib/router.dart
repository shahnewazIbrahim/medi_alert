import 'package:flutter/material.dart';
import 'package:medi_alert/screens/history_screen.dart';
import 'package:medi_alert/screens/home_screen.dart';
import 'package:medi_alert/screens/login_screen.dart';


Route<dynamic> onGenerateRoute(RouteSettings s) {
  switch (s.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case '/history':
      return MaterialPageRoute(builder: (_) => const HistoryScreen());
    default:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}
