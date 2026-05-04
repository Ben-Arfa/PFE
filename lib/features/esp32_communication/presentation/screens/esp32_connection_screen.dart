import 'package:flutter/material.dart';
import '../../../../shared/presentation/theme/app_colors.dart';
import '../../../../shared/presentation/theme/theme_provider.dart';

class Esp32ConnectionScreen extends StatefulWidget {
  const Esp32ConnectionScreen({super.key});

  @override
  State<Esp32ConnectionScreen> createState() => _Esp32ConnectionScreenState();
}

class _Esp32ConnectionScreenState extends State<Esp32ConnectionScreen> {
  final _ipCtrl = TextEditingController();
  final _portCtrl = TextEditingController();
  bool _isConnecting = false;

  @override
  void dispose() {
    _ipCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.instance;

    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
        backgroundColor: theme.headerColor,
        title: const Text('Connexion ESP32'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuration ESP32',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Entrez l\'adresse IP et le port de votre appareil ESP32',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _ipCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Adresse IP',
                hintText: '192.168.1.100',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Port',
                hintText: '81',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isConnecting ? null : _connect,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isConnecting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Connecter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connect() async {
    if (_ipCtrl.text.isEmpty || _portCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isConnecting = true);
    try {
      // TODO: Implement connection logic using use cases
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Connecté avec succès')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _isConnecting = false);
    }
  }
}
