import 'package:flutter/material.dart';
import '../app_theme.dart';

class GradientAppBar extends AppBar {
  GradientAppBar({super.key, required String titleText, List<Widget>? actions})
      : super(
    title: Text(titleText, style: const TextStyle(color: Colors.white)),
    elevation: 0,
    actions: actions,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
  );
}
