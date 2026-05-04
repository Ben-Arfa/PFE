import 'package:cloud_firestore/cloud_firestore.dart';

class FlockLot {
  final String id;
  final String identifier;
  final String buildingId;
  final String buildingName;
  final String poultryTypeId;
  final String poultryTypeName;
  final Timestamp entryDate;
  final int initialBirdCount;
  final int currentBirdCount;
  final bool isActive;
  final String provenance;
  final Timestamp createdAt;
  final Timestamp? closedAt;
  final int? closedSubjectsOut;
  final String? closureReason;
  final double? finalAvgWeightKg;
  final int? totalEggProduction;
  final Map<String, dynamic>? closureSummary;

  const FlockLot({
    required this.id,
    required this.identifier,
    required this.buildingId,
    required this.buildingName,
    required this.poultryTypeId,
    required this.poultryTypeName,
    required this.entryDate,
    required this.initialBirdCount,
    required this.currentBirdCount,
    required this.isActive,
    required this.provenance,
    required this.createdAt,
    this.closedAt,
    this.closedSubjectsOut,
    this.closureReason,
    this.finalAvgWeightKg,
    this.totalEggProduction,
    this.closureSummary,
  });

  Map<String, dynamic> toMap() => {
    'identifier': identifier,
    'buildingId': buildingId,
    'buildingName': buildingName,
    'poultryTypeId': poultryTypeId,
    'poultryTypeName': poultryTypeName,
    'entryDate': entryDate,
    'initialBirdCount': initialBirdCount,
    'currentBirdCount': currentBirdCount,
    'isActive': isActive,
    'provenance': provenance,
    'createdAt': createdAt,
    'closedAt': closedAt,
    'closedSubjectsOut': closedSubjectsOut,
    'closureReason': closureReason,
    'finalAvgWeightKg': finalAvgWeightKg,
    'totalEggProduction': totalEggProduction,
    'closureSummary': closureSummary,
  };

  factory FlockLot.fromMap(String id, Map<String, dynamic> map) {
    return FlockLot(
      id: id,
      identifier: map['identifier'] ?? '',
      buildingId: map['buildingId'] ?? '',
      buildingName: map['buildingName'] ?? '',
      poultryTypeId: map['poultryTypeId'] ?? '',
      poultryTypeName: map['poultryTypeName'] ?? '',
      entryDate: map['entryDate'] as Timestamp? ?? Timestamp.now(),
      initialBirdCount: (map['initialBirdCount'] ?? 0) as int,
      currentBirdCount: (map['currentBirdCount'] ?? 0) as int,
      isActive: map['isActive'] ?? false,
      provenance: map['provenance'] ?? '',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      closedAt: map['closedAt'] as Timestamp?,
      closedSubjectsOut: map['closedSubjectsOut'] as int?,
      closureReason: map['closureReason'] as String?,
      finalAvgWeightKg: map['finalAvgWeightKg'] != null
          ? (map['finalAvgWeightKg'] as num).toDouble()
          : null,
      totalEggProduction: map['totalEggProduction'] as int?,
      closureSummary: map['closureSummary'] as Map<String, dynamic>?,
    );
  }
}
