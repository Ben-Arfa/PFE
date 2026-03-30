// lib/core/models.dart
// Modèles de données de l'application KIWO.
// PoultryType supprimé — l'utilisateur configure librement son élevage.

// ─────────────────────────────────────────────────────────────────
// SystemConfig — entièrement libre, saisi par l'utilisateur
// ─────────────────────────────────────────────────────────────────

class SystemConfig {
  // Informations générales
  String farmName = ''; // Nom de l'élevage (ex: Lot A)
  String poultryType = ''; // Texte libre (ex: Poulet fermier)
  String objective = ''; // Texte libre (ex: Production d'oeufs)

  // Bâtiment
  int birdCount = 0;
  double surfaceM2 = 0;

  // Seuils capteurs
  double tempMin = 20;
  double tempMax = 32;
  double humMin = 50;
  double humMax = 70;
  double co2Max = 3000;
  double ammoniacMax = 20;
  double lightHours = 16;
  double waterAlertPct = 25;
  double foodAlertPct = 25;

  // Automatismes
  bool autoVentilation = true;
  bool autoHeating = true;
  bool autoLighting = true;
  bool autoFeeding = false;
  bool autoWatering = false;

  // État système
  bool systemRunning = false;

  bool get isConfigured =>
      farmName.isNotEmpty && poultryType.isNotEmpty && birdCount > 0;

  Map<String, dynamic> toMap() => {
    'farmName': farmName,
    'poultryType': poultryType,
    'objective': objective,
    'birdCount': birdCount,
    'surfaceM2': surfaceM2,
    'tempMin': tempMin,
    'tempMax': tempMax,
    'humMin': humMin,
    'humMax': humMax,
    'co2Max': co2Max,
    'ammoniacMax': ammoniacMax,
    'lightHours': lightHours,
    'waterAlertPct': waterAlertPct,
    'foodAlertPct': foodAlertPct,
    'autoVentilation': autoVentilation,
    'autoHeating': autoHeating,
    'autoLighting': autoLighting,
    'autoFeeding': autoFeeding,
    'autoWatering': autoWatering,
    'systemRunning': systemRunning,
  };

  void fromMap(Map<String, dynamic> m) {
    farmName = m['farmName'] ?? '';
    poultryType = m['poultryType'] ?? '';
    objective = _normalizeObjective(m['objective']);
    birdCount = (m['birdCount'] ?? 0).toInt();
    surfaceM2 = (m['surfaceM2'] ?? 0).toDouble();
    tempMin = (m['tempMin'] ?? 20).toDouble();
    tempMax = (m['tempMax'] ?? 32).toDouble();
    humMin = (m['humMin'] ?? 50).toDouble();
    humMax = (m['humMax'] ?? 70).toDouble();
    co2Max = (m['co2Max'] ?? 3000).toDouble();
    ammoniacMax = (m['ammoniacMax'] ?? 20).toDouble();
    lightHours = (m['lightHours'] ?? 16).toDouble();
    waterAlertPct = (m['waterAlertPct'] ?? 25).toDouble();
    foodAlertPct = (m['foodAlertPct'] ?? 25).toDouble();
    autoVentilation = m['autoVentilation'] ?? true;
    autoHeating = m['autoHeating'] ?? true;
    autoLighting = m['autoLighting'] ?? true;
    autoFeeding = m['autoFeeding'] ?? false;
    autoWatering = m['autoWatering'] ?? false;
    systemRunning = m['systemRunning'] ?? false;
  }

  String _normalizeObjective(dynamic raw) {
    final value = (raw ?? '').toString().trim();
    switch (value) {
      case 'meat':
        return 'Viande';
      case 'eggs':
        return 'Oeufs';
      case 'foieGras':
        return 'Foie gras';
      case 'mixed':
        return 'Mixte';
      default:
        return value;
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// SystemState
// ─────────────────────────────────────────────────────────────────

enum SystemState { idle, running, paused, alert }

class SensorReading {
  final String sensorId;
  final double value;
  final DateTime timestamp;
  final bool connected;

  const SensorReading({
    required this.sensorId,
    required this.value,
    required this.timestamp,
    required this.connected,
  });
}

class SensorState {
  final String id;
  final String label;
  final String unit;
  final double value;
  final double min;
  final double max;
  final bool connected;
  final List<SensorReading> history;

  const SensorState({
    required this.id,
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.connected,
    required this.history,
  });
}
