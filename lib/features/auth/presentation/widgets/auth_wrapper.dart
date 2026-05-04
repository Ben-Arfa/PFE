import 'package:flutter/material.dart';
import 'package:kiwo/app/di/service_locator.dart';
import 'package:kiwo/features/auth/domain/entities/user_profile.dart';
import 'package:kiwo/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:kiwo/features/home/presentation/screens/home_screen.dart';
import '../screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authUseCases = ServiceLocator.instance.authUseCases;
    return StreamBuilder<bool>(
      stream: authUseCases.watchAuthentication(),
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

        if (snapshot.data != true) {
          return const LoginScreen();
        }

        return StreamBuilder<UserProfile?>(
          stream: authUseCases.watchCurrentUserProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
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

            final role = authUseCases.resolveRole(profileSnapshot.data);
            return role == 'admin'
                ? const AdminDashboardScreen()
                : const HomeScreen();
          },
        );
      },
    );
  }
}
