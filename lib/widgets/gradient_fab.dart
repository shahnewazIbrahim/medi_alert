import 'package:flutter/material.dart';
import '../app_theme.dart';

class GradientFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  const GradientFAB({super.key, required this.onPressed, this.icon = Icons.add});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      elevation: 6,
      child: Ink(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppTheme.primaryDark, AppTheme.primaryLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const SizedBox(
          width: 56, height: 56,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
