import 'package:cloud_firestore/cloud_firestore.dart';

class DailyEntry {
  final String id;
  final String lotId;
  final Timestamp date;
  final int deathsToday;
  final int? eggsToday;
  final double? avgWeightKg;
  final double feedKg;
  final double waterL;
  final String? observations;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  DailyEntry({
    required this.id,
    required this.lotId,
    required this.date,
    required this.deathsToday,
    this.eggsToday,
    this.avgWeightKg,
    required this.feedKg,
    required this.waterL,
    this.observations,
    this.createdAt,
    this.updatedAt,
  });

  factory DailyEntry.fromMap(String id, Map<String, dynamic> map) {
    return DailyEntry(
      id: id,
      lotId: map['lotId'] as String? ?? '',
      date: map['date'] as Timestamp? ?? Timestamp.now(),
      deathsToday: (map['deathsToday'] ?? 0) as int,
      eggsToday: (map['eggsToday'] as int?),
      avgWeightKg: map['avgWeightKg'] != null
          ? (map['avgWeightKg'] as num).toDouble()
          : null,
      feedKg: map['feedKg'] != null ? (map['feedKg'] as num).toDouble() : 0.0,
      waterL: map['waterL'] != null ? (map['waterL'] as num).toDouble() : 0.0,
      observations: map['observations'] as String?,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() => {
    'lotId': lotId,
    'date': date,
    'deathsToday': deathsToday,
    'eggsToday': eggsToday,
    'avgWeightKg': avgWeightKg,
    'feedKg': feedKg,
    'waterL': waterL,
    'observations': observations,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
