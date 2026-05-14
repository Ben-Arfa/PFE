import 'package:cloud_firestore/cloud_firestore.dart';

class SensorReading {
  final String id;
  final String deviceId;
  final double temperature;
  final double humidity;
  final double? co2;
  final double? pressure;
  final double? light;
  final DateTime timestamp;
  final Map<String, dynamic> additionalData;

  SensorReading({
    required this.id,
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    this.co2,
    this.pressure,
    this.light,
    required this.timestamp,
    this.additionalData = const {},
  });

  factory SensorReading.fromMap(Map<String, dynamic> map, String docId) {
    final ts = map['timestamp'];
    DateTime date;
    if (ts is Timestamp) {
      date = ts.toDate();
    } else if (ts is DateTime) {
      date = ts;
    } else {
      date = DateTime.now();
    }

    return SensorReading(
      id: docId,
      deviceId: map['deviceId'] as String? ?? '',
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (map['humidity'] as num?)?.toDouble() ?? 0.0,
      co2: (map['co2'] as num?)?.toDouble(),
      pressure: (map['pressure'] as num?)?.toDouble(),
      light: (map['light'] as num?)?.toDouble(),
      timestamp: date,
      additionalData: map['additionalData'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'temperature': temperature,
      'humidity': humidity,
      'co2': co2,
      'pressure': pressure,
      'light': light,
      'timestamp': Timestamp.fromDate(timestamp),
      'additionalData': additionalData,
    };
  }

  SensorReading copyWith({
    String? id,
    String? deviceId,
    double? temperature,
    double? humidity,
    double? co2,
    double? pressure,
    double? light,
    DateTime? timestamp,
    Map<String, dynamic>? additionalData,
  }) {
    return SensorReading(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      co2: co2 ?? this.co2,
      pressure: pressure ?? this.pressure,
      light: light ?? this.light,
      timestamp: timestamp ?? this.timestamp,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
