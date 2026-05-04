import 'package:cloud_firestore/cloud_firestore.dart';

import 'farm_management_inputs.dart';

class PoultryType {
  final String id;
  final String name;
  final PoultryCategory category;
  final double targetTempMin;
  final double targetTempMax;
  final double targetHumidityMin;
  final double targetHumidityMax;
  final double recommendedDensity;
  final double recommendedLightHours;
  final int typicalDurationDays;
  final double targetValue;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const PoultryType({
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
    required this.targetValue,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Building {
  final String id;
  final String name;
  final double areaM2;
  final int capacityMax;
  final BuildingStatus status;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const Building({
    required this.id,
    required this.name,
    required this.areaM2,
    required this.capacityMax,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}

class FlockLot {
  final String id;
  final String identifier;
  final String buildingId;
  final String buildingName;
  final String poultryTypeId;
  final String poultryTypeName;
  final PoultryCategory category;
  final DateTime entryDate;
  final int initialBirdCount;
  final int currentBirdCount;
  final int totalDeaths;
  final bool isActive;
  final String supplier;
  final Timestamp createdAt;
  final LotClosureSummary? summary;

  const FlockLot({
    required this.id,
    required this.identifier,
    required this.buildingId,
    required this.buildingName,
    required this.poultryTypeId,
    required this.poultryTypeName,
    required this.category,
    required this.entryDate,
    required this.initialBirdCount,
    required this.currentBirdCount,
    required this.totalDeaths,
    required this.isActive,
    required this.supplier,
    required this.createdAt,
    this.summary,
  });
}

class DailyEntry {
  final String id;
  final String lotId;
  final DateTime entryDate;
  final int dailyMortality;
  final double cumulativeMortalityRate;
  final double feedKg;
  final double waterLiters;
  final String notes;
  final double? averageWeightKg;
  final double? dailyWeightGainG;
  final double? feedConversionRatio;
  final int? eggCount;
  final double? layRate;
  final double? peakLayRate;

  const DailyEntry({
    required this.id,
    required this.lotId,
    required this.entryDate,
    required this.dailyMortality,
    required this.cumulativeMortalityRate,
    required this.feedKg,
    required this.waterLiters,
    required this.notes,
    this.averageWeightKg,
    this.dailyWeightGainG,
    this.feedConversionRatio,
    this.eggCount,
    this.layRate,
    this.peakLayRate,
  });
}

class LotClosureSummary {
  final DateTime? exitDate;
  final int? finalBirdCount;
  final double? cumulativeMortalityRate;
  final double? averageFinalWeightKg;
  final int? totalEggProduction;

  const LotClosureSummary({
    this.exitDate,
    this.finalBirdCount,
    this.cumulativeMortalityRate,
    this.averageFinalWeightKg,
    this.totalEggProduction,
  });
}

class LotJournalEvent {
  final String id;
  final String lotId;
  final JournalEventType type;
  final String title;
  final String description;
  final DateTime occurredAt;

  const LotJournalEvent({
    required this.id,
    required this.lotId,
    required this.type,
    required this.title,
    required this.description,
    required this.occurredAt,
  });
}
