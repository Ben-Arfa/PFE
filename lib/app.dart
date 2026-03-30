// lib/app.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/auth_wrapper.dart';
import 'core/theme_provider.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthWrapper()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeProvider.instance,
      builder: (context, _) {
        final isDark = ThemeProvider.instance.isDark;
        return MaterialApp.router(
          title: 'Kiwo',
          debugShowCheckedModeBanner: false,
          theme: ThemeProvider.instance.lightTheme,
          darkTheme: ThemeProvider.instance.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          routerConfig: _router,
        );
      },
    );
  }
}
