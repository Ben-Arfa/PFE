// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'features/suivi_des_vaccinations/data/services/vaccination_notification_service.dart';
import 'shared/presentation/theme/theme_provider.dart';
import 'app/presentation/kiwo_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ThemeProvider.instance.init(); // ← charge la préférence sauvegardée
  try {
    await VaccinationNotificationService.instance.init();
  } catch (_) {
    // Les rappels locaux restent optionnels pour ne pas bloquer le lancement.
  }

  runApp(const MyApp());
}
