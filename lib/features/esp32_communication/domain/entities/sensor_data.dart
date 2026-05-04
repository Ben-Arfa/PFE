class SensorData {
  final String sensorId;
  final String sensorName;
  final double value;
  final String unit;
  final DateTime timestamp;

  const SensorData({
    required this.sensorId,
    required this.sensorName,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      sensorId: json['id'] as String? ?? '',
      sensorName: json['name'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': sensorId,
    'name': sensorName,
    'value': value,
    'unit': unit,
    'timestamp': timestamp.toIso8601String(),
  };
}
