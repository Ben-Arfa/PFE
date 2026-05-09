import 'package:flutter/material.dart';
import 'package:kiwo/core/theme_provider.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes'),
        backgroundColor: theme.headerColor,
        foregroundColor: theme.textColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Ici apparaîtront les alertes critiques et messages importants.',
            style: TextStyle(color: theme.mutedColor),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
