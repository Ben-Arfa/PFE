import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import '../home/screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A0F),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C63FF),
                strokeWidth: 2.5,
              ),
            ),
          );
        }
        return snapshot.hasData ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
