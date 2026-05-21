import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/sensor_reading.dart';

class Esp32Dht22Service {
  Esp32Dht22Service({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<SensorReading> fetchReading({
    required String baseUrl,
    required String deviceId,
  }) async {
    final uri = _readingsUri(baseUrl);
    final response = await _client.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('ESP32 indisponible (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Reponse ESP32 invalide');
    }

    final temperature = _readDouble(decoded, ['temperature', 'temp']);
    final humidity = _readDouble(decoded, ['humidity', 'humidite']);

    if (temperature == null || humidity == null) {
      throw Exception('Temperature ou humidite manquante');
    }

    return SensorReading(
      id: '',
      deviceId: deviceId,
      temperature: temperature,
      humidity: humidity,
      timestamp: DateTime.now(),
      additionalData: {
        'source': 'esp32-dht22',
        'esp32Url': uri.toString(),
        if (decoded['heatIndex'] != null) 'heatIndex': decoded['heatIndex'],
        if (decoded['rssi'] != null) 'rssi': decoded['rssi'],
        if (decoded['uptimeMs'] != null) 'uptimeMs': decoded['uptimeMs'],
      },
    );
  }

  Uri _readingsUri(String baseUrl) {
    final normalized = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final withScheme = normalized.startsWith('http://') ||
            normalized.startsWith('https://')
        ? normalized
        : 'http://$normalized';
    return Uri.parse('$withScheme/readings');
  }

  double? _readDouble(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
    }
    return null;
  }
}
