import 'package:cloud_firestore/cloud_firestore.dart';

enum BuildingStatus { active, empty, disinfecting }

extension BuildingStatusX on BuildingStatus {
  String get label {
    switch (this) {
      case BuildingStatus.active:
        return 'Actif';
      case BuildingStatus.empty:
        return 'Vide';
      case BuildingStatus.disinfecting:
        return 'En désinfection';
    }
  }

  String get value => name;

  static BuildingStatus fromValue(String? value) {
    return BuildingStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => BuildingStatus.empty,
    );
  }
}

class Building {
  final String id;
  final String name;
  final double areaM2;
  final int capacityMax;
  final BuildingStatus status;
  final String? activeLotId;
  final String? activePoultryTypeId;
  final String? activePoultryTypeName;
  final double? targetTempMin;
  final double? targetTempMax;
  final double? targetHumidityMin;
  final double? targetHumidityMax;
  final double? recommendedDensity;
  final double? recommendedLightHours;
  final int? typicalDurationDays;
  final double? targetWeightKg;
  final int? layStartAgeDays;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const Building({
    required this.id,
    required this.name,
    required this.areaM2,
    required this.capacityMax,
    required this.status,
    this.activeLotId,
    this.activePoultryTypeId,
    this.activePoultryTypeName,
    this.targetTempMin,
    this.targetTempMax,
    this.targetHumidityMin,
    this.targetHumidityMax,
    this.recommendedDensity,
    this.recommendedLightHours,
    this.typicalDurationDays,
    this.targetWeightKg,
    this.layStartAgeDays,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'areaM2': areaM2,
    'capacityMax': capacityMax,
    'status': status.value,
    'activeLotId': activeLotId,
    'activePoultryTypeId': activePoultryTypeId,
    'activePoultryTypeName': activePoultryTypeName,
    'targetTempMin': targetTempMin,
    'targetTempMax': targetTempMax,
    'targetHumidityMin': targetHumidityMin,
    'targetHumidityMax': targetHumidityMax,
    'recommendedDensity': recommendedDensity,
    'recommendedLightHours': recommendedLightHours,
    'typicalDurationDays': typicalDurationDays,
    'targetWeightKg': targetWeightKg,
    'layStartAgeDays': layStartAgeDays,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory Building.fromMap(String id, Map<String, dynamic> map) {
    return Building(
      id: id,
      name: map['name'] ?? '',
      areaM2: (map['areaM2'] ?? 0).toDouble(),
      capacityMax: (map['capacityMax'] ?? 0) as int,
      status: BuildingStatusX.fromValue(map['status'] as String?),
      activeLotId: map['activeLotId'] as String?,
      activePoultryTypeId: map['activePoultryTypeId'] as String?,
      activePoultryTypeName: map['activePoultryTypeName'] as String?,
      targetTempMin: map['targetTempMin'] != null
          ? (map['targetTempMin'] as num).toDouble()
          : null,
      targetTempMax: map['targetTempMax'] != null
          ? (map['targetTempMax'] as num).toDouble()
          : null,
      targetHumidityMin: map['targetHumidityMin'] != null
          ? (map['targetHumidityMin'] as num).toDouble()
          : null,
      targetHumidityMax: map['targetHumidityMax'] != null
          ? (map['targetHumidityMax'] as num).toDouble()
          : null,
      recommendedDensity: map['recommendedDensity'] != null
          ? (map['recommendedDensity'] as num).toDouble()
          : null,
      recommendedLightHours: map['recommendedLightHours'] != null
          ? (map['recommendedLightHours'] as num).toDouble()
          : null,
      typicalDurationDays: map['typicalDurationDays'] as int?,
      targetWeightKg: map['targetWeightKg'] != null
          ? (map['targetWeightKg'] as num).toDouble()
          : null,
      layStartAgeDays: map['layStartAgeDays'] as int?,
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}
