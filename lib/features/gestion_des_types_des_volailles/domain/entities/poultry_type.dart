import 'package:cloud_firestore/cloud_firestore.dart';

class PoultryType {
  final String id;
  final String name;
  final String category; // 'chair' or 'pondeuse'
  final double targetTempMin;
  final double targetTempMax;
  final double targetHumidityMin;
  final double targetHumidityMax;
  final double recommendedDensity;
  final double recommendedLightHours;
  final int typicalDurationDays;
  final double? targetWeightKg; // for chair
  final int? layStartAgeDays; // for pondeuse
  final Timestamp createdAt;
  final Timestamp updatedAt;

  PoultryType({
    required this.id,
    required this.name,
    required this.category,
    required this.targetTempMin,
    required this.targetTempMax,
    required this.targetHumidityMin,
    required this.targetHumidityMax,
    required this.recommendedDensity,
    required this.recommendedLightHours,
    required this.typicalDurationDays,
    this.targetWeightKg,
    this.layStartAgeDays,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
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

  factory PoultryType.fromMap(String id, Map<String, dynamic> map) {
    return PoultryType(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? 'chair',
      targetTempMin: (map['targetTempMin'] ?? 0).toDouble(),
      targetTempMax: (map['targetTempMax'] ?? 0).toDouble(),
      targetHumidityMin: (map['targetHumidityMin'] ?? 0).toDouble(),
      targetHumidityMax: (map['targetHumidityMax'] ?? 0).toDouble(),
      recommendedDensity: (map['recommendedDensity'] ?? 0).toDouble(),
      recommendedLightHours: (map['recommendedLightHours'] ?? 0).toDouble(),
      typicalDurationDays: (map['typicalDurationDays'] ?? 0) as int,
      targetWeightKg: map['targetWeightKg'] != null
          ? (map['targetWeightKg'] as num).toDouble()
          : null,
      layStartAgeDays: map['layStartAgeDays'] != null
          ? (map['layStartAgeDays'] as int)
          : null,
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}
