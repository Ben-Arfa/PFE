import 'package:flutter/material.dart';
import 'package:kiwo/core/theme_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final theme = ThemeProvider.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: theme.headerColor,
        foregroundColor: theme.textColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Ici apparaîtront les notifications planifiées et reçues.',
            style: TextStyle(color: theme.mutedColor, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
