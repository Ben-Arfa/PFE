# Guide d'Intégration ESP32

## 1. Installation des dépendances

Assure-toi que tu as `get_it` dans ton `pubspec.yaml`:

```yaml
dev_dependencies:
  get_it: ^7.6.0
```

## 2. Configuration du Service Locator

Ouvre ton fichier `lib/app/di/service_locator.dart` (ou équivalent) et ajoute:

```dart
import 'package:kiwo/features/esp32_communication/esp32_communication.dart';

void setupServiceLocator() {
  // ... tes autres configurations ...
  
  // ESP32 Communication Setup
  setupEsp32Dependencies(getIt);
}
```

## 3. Intégration dans le menu Elevage

Ajoute ESP32 au menu d'Elevage dans `lib/features/home/presentation/screens/elevage_screen.dart`:

```dart
// Dans l'enum _ElevageSection
enum _ElevageSection { 
  menu, 
  types, 
  buildings, 
  lots, 
  saisie, 
  vaccinations,
  esp32  // ← AJOUTER
}

// Dans le switch du build()
case _ElevageSection.esp32:
  return Esp32ConnectionScreen();

// Dans le menu buttons
ElevageMenuButton(
  label: 'Communication ESP32',
  icon: Icons.router,  // ou Icons.device_unknown
  onPressed: () => setState(() => _section = _ElevageSection.esp32),
),
```

## 4. Utilisation dans tes écrans

```dart
import 'package:kiwo/features/esp32_communication/esp32_communication.dart';

class MaScreen extends StatefulWidget {
  @override
  State<MaScreen> createState() => _MaScreenState();
}

class _MaScreenState extends State<MaScreen> {
  late Esp32Repository _repository;
  
  @override
  void initState() {
    super.initState();
    _repository = getIt<Esp32Repository>();
  }
  
  Future<void> _connectToEsp32() async {
    final connectUseCase = getIt<ConnectToEsp32UseCase>();
    final success = await connectUseCase('192.168.1.100', 81);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecté!')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorData>(
      stream: getIt<WatchSensorDataUseCase>()('temperature'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final data = snapshot.data!;
        return SensorDataCard(sensorData: data);
      },
    );
  }
}
```

## 5. Architecture complète

```
esp32_communication/
├── domain/
│   ├── entities/
│   │   ├── esp32_device.dart          # Modèle du dispositif
│   │   └── sensor_data.dart           # Données capteur
│   ├── repositories/
│   │   └── esp32_repository.dart      # Interface abstraite
│   └── usecases/
│       ├── connect_to_esp32_usecase.dart
│       └── watch_sensor_data_usecase.dart
├── data/
│   ├── datasources/
│   │   └── esp32_dependency_injection.dart  # Configuration DI
│   ├── models/
│   │   └── esp32_device_model.dart
│   ├── repositories/
│   │   └── esp32_repository_impl.dart  # Implémentation
│   └── services/
│       └── esp32_service.dart          # Communication WebSocket
└── presentation/
    ├── screens/
    │   └── esp32_connection_screen.dart
    └── widgets/
        ├── esp32_connection_indicator.dart
        ├── sensor_data_card.dart
        └── sensor_data_grid.dart
```

## 6. Protocole de communication ESP32

Ton ESP32 doit exécuter un serveur WebSocket qui envoie les données au format JSON:

```json
{
  "id": "temperature_sensor",
  "name": "Température",
  "value": 23.5,
  "unit": "°C",
  "timestamp": "2026-05-03T14:30:00Z"
}
```

Pour contrôler l'ESP32:

```dart
await _repository.sendCommand('SET_LED_ON');
await _repository.sendCommand('SET_FAN_SPEED:75');
```

## 7. Gestion de la déconnexion

```dart
@override
void dispose() {
  _repository.disconnect();
  super.dispose();
}
```

## Notes importantes

- ✅ Respecte l'architecture feature-based existante
- ✅ Utilise les mêmes couleurs (AppColors) et le ThemeProvider
- ✅ Les imports sont centralisés dans `esp32_communication.dart`
- ⚠️ Adapte l'URL WebSocket selon ta config ESP32
- ⚠️ Gère les erreurs de connexion (timeout, WiFi down, etc.)
- ⚠️ Teste d'abord en développement avant la production
