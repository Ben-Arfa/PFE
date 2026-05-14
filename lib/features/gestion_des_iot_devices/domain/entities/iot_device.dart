import 'package:cloud_firestore/cloud_firestore.dart';

class IotDevice {
  final String id;
  final String deviceId;
  final String name;
  final String type; // 'temperature', 'humidity', 'multi-sensor', etc.
  final String buildingId;
  final String lotId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastSync;
  final Map<String, dynamic> metadata; // For extra data

  IotDevice({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.type,
    required this.buildingId,
    required this.lotId,
    required this.isActive,
    required this.createdAt,
    this.lastSync,
    this.metadata = const {},
  });

  factory IotDevice.fromMap(Map<String, dynamic> map, String docId) {
    return IotDevice(
      id: docId,
      deviceId: map['deviceId'] as String? ?? docId,
      name: map['name'] as String? ?? 'Appareil IoT',
      type: map['type'] as String? ?? 'multi-sensor',
      buildingId: map['buildingId'] as String? ?? '',
      lotId: map['lotId'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSync: (map['lastSync'] as Timestamp?)?.toDate(),
      metadata: map['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'name': name,
      'type': type,
      'buildingId': buildingId,
      'lotId': lotId,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSync': lastSync != null ? Timestamp.fromDate(lastSync!) : null,
      'metadata': metadata,
    };
  }

  IotDevice copyWith({
    String? id,
    String? deviceId,
    String? name,
    String? type,
    String? buildingId,
    String? lotId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastSync,
    Map<String, dynamic>? metadata,
  }) {
    return IotDevice(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      type: type ?? this.type,
      buildingId: buildingId ?? this.buildingId,
      lotId: lotId ?? this.lotId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastSync: lastSync ?? this.lastSync,
      metadata: metadata ?? this.metadata,
    );
  }
}
