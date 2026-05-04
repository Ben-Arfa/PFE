import '../../domain/entities/esp32_device.dart';

class Esp32DeviceModel extends Esp32Device {
  const Esp32DeviceModel({
    required super.id,
    required super.ipAddress,
    required super.port,
    required super.name,
    required super.lastConnected,
    required super.isConnected,
  });

  factory Esp32DeviceModel.fromJson(Map<String, dynamic> json) {
    return Esp32DeviceModel(
      id: json['id'] as String? ?? '',
      ipAddress: json['ipAddress'] as String? ?? '',
      port: json['port'] as int? ?? 80,
      name: json['name'] as String? ?? 'Unknown Device',
      lastConnected: json['lastConnected'] != null
          ? DateTime.parse(json['lastConnected'] as String)
          : DateTime.now(),
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ipAddress': ipAddress,
    'port': port,
    'name': name,
    'lastConnected': lastConnected.toIso8601String(),
    'isConnected': isConnected,
  };
}
