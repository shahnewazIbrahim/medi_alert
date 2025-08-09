import 'package:flutter/material.dart';
import '../app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final pass  = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryDark, AppTheme.primaryLight],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.medical_services, size: 80, color: AppTheme.primaryDark),
                    const SizedBox(height: 16),
                    const Text('MediAlert Login', style: TextStyle(fontSize:24, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        filled: true, fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pass, obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        filled: true, fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          // UI-only: pretend login then go home
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: const Text('Login', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registration UI only in this sprint')),
                      ),
                      child: const Text('Create New Account', style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
