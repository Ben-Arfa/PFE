import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/index.dart';

/// Réponse complète de l'ESP32
class Esp32DataResponse {
  final double temperature;
  final double humidity;
  final bool readingOk;
  final String mode; // 'auto' ou 'manuel'
  final double tempMin;
  final double tempMax;
  final double humidityMin;
  final double humidityMax;
  final List<bool> leds;
  final List<String> alerts;

  Esp32DataResponse({
    required this.temperature,
    required this.humidity,
    required this.readingOk,
    required this.mode,
    required this.tempMin,
    required this.tempMax,
    required this.humidityMin,
    required this.humidityMax,
    required this.leds,
    required this.alerts,
  });

  factory Esp32DataResponse.fromJson(Map<String, dynamic> json) {
    return Esp32DataResponse(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      readingOk: json['readingOk'] as bool? ?? false,
      mode: json['mode'] as String? ?? 'auto',
      tempMin: (json['tempMin'] as num?)?.toDouble() ?? 18.0,
      tempMax: (json['tempMax'] as num?)?.toDouble() ?? 30.0,
      humidityMin: (json['humidityMin'] as num?)?.toDouble() ?? 40.0,
      humidityMax: (json['humidityMax'] as num?)?.toDouble() ?? 80.0,
      leds:
          (json['leds'] as List?)?.map((e) => e as bool).toList() ??
          List.filled(4, false),
      alerts:
          (json['alerts'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  /// Retourne un label lisible pour chaque alerte
  String get alertsSummary {
    if (alerts.isEmpty) return '';
    return alerts
        .map((a) {
          switch (a) {
            case 'temp_high':
              return '🌡️ Température trop haute';
            case 'temp_low':
              return '❄️ Température trop basse';
            case 'humidity_high':
              return '💧 Humidité trop haute';
            case 'humidity_low':
              return '🏜️ Humidité trop basse';
            default:
              return a;
          }
        })
        .join(', ');
  }

  bool get hasAlerts => alerts.isNotEmpty;
}

/// Service de communication HTTP avec l'ESP32
class Esp32Dht22Service {
  final Duration _timeout = const Duration(seconds: 8);

  // ─── Lecture des données DHT22 ──────────────────────────────────────────

  /// Récupère température, humidité, état LEDs et alertes depuis l'ESP32
  /// Retourne aussi un [SensorReading] prêt à être sauvegardé en Firestore
  Future<SensorReading> fetchReading({
    required String baseUrl,
    required String deviceId,
  }) async {
    final response = await http
        .get(Uri.parse('$baseUrl/data'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('ESP32 erreur ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = Esp32DataResponse.fromJson(json);

    if (!data.readingOk) {
      throw Exception('Lecture DHT22 invalide (capteur non prêt)');
    }

    return SensorReading(
      id: '',
      deviceId: deviceId,
      temperature: data.temperature,
      humidity: data.humidity,
      timestamp: DateTime.now(),
      additionalData: {
        'leds': data.leds,
        'alerts': data.alerts,
        'mode': data.mode,
        'tempMin': data.tempMin,
        'tempMax': data.tempMax,
        'humidityMin': data.humidityMin,
        'humidityMax': data.humidityMax,
      },
    );
  }

  /// Récupère toutes les données ESP32 (pour affichage dashboard)
  Future<Esp32DataResponse> fetchData({required String baseUrl}) async {
    final response = await http
        .get(Uri.parse('$baseUrl/data'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('ESP32 erreur ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Esp32DataResponse.fromJson(json);
  }

  // ─── Envoi des seuils ───────────────────────────────────────────────────

  /// Envoie les seuils du bâtiment à l'ESP32 (depuis PoultryType/Building)
  Future<void> sendSeuils({
    required String baseUrl,
    required double tempMin,
    required double tempMax,
    required double humidityMin,
    required double humidityMax,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/seuils'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'tempMin': tempMin,
            'tempMax': tempMax,
            'humidityMin': humidityMin,
            'humidityMax': humidityMax,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erreur envoi seuils: ${response.statusCode}');
    }
  }

  // ─── Contrôle LED (override manuel) ────────────────────────────────────

  /// Contrôle manuel d'une LED (index 0-3)
  /// LED 0 = Ventilation | LED 1 = Chauffage | LED 2 = Alarme | LED 3 = Statut
  Future<void> setLed({
    required String baseUrl,
    required int index,
    required bool state,
  }) async {
    assert(index >= 0 && index < 4, 'Index LED doit être entre 0 et 3');

    final response = await http
        .post(
          Uri.parse('$baseUrl/led'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'index': index, 'state': state}),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erreur contrôle LED: ${response.statusCode}');
    }
  }

  // ─── Mode auto/manuel ───────────────────────────────────────────────────

  /// Bascule entre mode "auto" et "manuel"
  Future<void> setMode({
    required String baseUrl,
    required String mode, // 'auto' ou 'manuel'
  }) async {
    assert(mode == 'auto' || mode == 'manuel', 'Mode invalide');

    final response = await http
        .post(
          Uri.parse('$baseUrl/mode'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'mode': mode}),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erreur changement de mode: ${response.statusCode}');
    }
  }

  // ─── Statut système ─────────────────────────────────────────────────────

  /// Vérifie que l'ESP32 est joignable
  Future<bool> ping({required String baseUrl}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/status'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
