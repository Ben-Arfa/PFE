# ESP32 Communication Feature

Cette feature gère la communication entre l'app Flutter et un appareil ESP32 via WebSocket.

## Structure

```
esp32_communication/
├── domain/          # Logique métier
│   ├── entities/    # SensorData, Esp32Device
│   ├── repositories/# Interfaces abstraites
│   └── usecases/    # Cas d'usage
├── data/            # Sources de données
│   ├── datasources/ # HTTP, WebSocket clients
│   ├── models/      # Extensions des entities
│   ├── repositories/# Implémentations
│   └── services/    # Esp32Service
└── presentation/    # UI
    ├── screens/     # Esp32ConnectionScreen, ...
    └── widgets/     # Composants réutilisables
```

## Utilisation

1. **Connecter à l'ESP32:**
```dart
final useCase = ConnectToEsp32UseCase(repository);
await useCase('192.168.1.100', 81);
```

2. **Écouter les données des capteurs:**
```dart
final watchUseCase = WatchSensorDataUseCase(repository);
final stream = watchUseCase('temperature_sensor');
stream.listen((data) {
  print('Température: ${data.value}${data.unit}');
});
```

3. **Envoyer des commandes:**
```dart
await repository.sendCommand('SET_LED_ON');
```

## Notes

- Le service utilise WebSocket pour la communication en temps réel
- Adapter l'URL WebSocket selon votre configuration ESP32
- Implémenter les méthodes `fetchLatestSensorData()` et `getDeviceInfo()` selon votre API ESP32
