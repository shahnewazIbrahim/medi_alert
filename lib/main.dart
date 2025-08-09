import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MediAlertApp());
}

class MediAlertApp extends StatelessWidget {
  const MediAlertApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediAlert (UI Demo)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      onGenerateRoute: onGenerateRoute,
      initialRoute: '/login',
    );
  }
}
