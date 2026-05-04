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

class CreateLotInput {
  final String identifier;
  final String poultryTypeId;
  final String buildingId;
  final DateTime entryDate;
  final int initialBirdCount;
  final String supplier;

  const CreateLotInput({
    required this.identifier,
    required this.poultryTypeId,
    required this.buildingId,
    required this.entryDate,
    required this.initialBirdCount,
    required this.supplier,
  });
}

class BuildingInput {
  final String name;
  final double areaM2;
  final int capacityMax;
  final BuildingStatus status;

  const BuildingInput({
    required this.name,
    required this.areaM2,
    required this.capacityMax,
    required this.status,
  });
}

class CloseLotInput {
  final String lotId;
  final DateTime exitDate;
  final int finalBirdCount;
  final double? averageFinalWeightKg;
  final LotExitReason? exitReason;
  final int? totalEggProduction;

  const CloseLotInput({
    required this.lotId,
    required this.exitDate,
    required this.finalBirdCount,
    this.averageFinalWeightKg,
    this.exitReason,
    this.totalEggProduction,
  });
}

class CreateDailyEntryInput {
  final String lotId;
  final DateTime entryDate;
  final int dailyMortality;
  final double feedKg;
  final double waterLiters;
  final String notes;
  final double? averageWeightKg;
  final int? eggCount;

  const CreateDailyEntryInput({
    required this.lotId,
    required this.entryDate,
    required this.dailyMortality,
    required this.feedKg,
    required this.waterLiters,
    required this.notes,
    this.averageWeightKg,
    this.eggCount,
  });
}

class AddJournalNoteInput {
  final String lotId;
  final JournalEventType type;
  final String title;
  final String description;
  final DateTime occurredAt;

  const AddJournalNoteInput({
    required this.lotId,
    required this.type,
    required this.title,
    required this.description,
    required this.occurredAt,
  });
}

class PoultryTypeInput {
  final String name;
  final PoultryCategory category;
  final double targetTempMin;
  final double targetTempMax;
  final double targetHumidityMin;
  final double targetHumidityMax;
  final double recommendedDensity;
  final double recommendedLightHours;
  final int typicalDurationDays;
  final double? targetWeightKg;
  final int? layStartAgeDays;
  final double targetValue;

  const PoultryTypeInput({
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
    required this.targetValue,
  });
}

enum LotExitReason { slaughter, sale, mortality, transfer }

enum JournalEventType { entry, dailyEntry, vaccination, alert, closure }

enum PoultryCategory { meat, layer }

extension PoultryCategoryX on PoultryCategory {
  String get label {
    switch (this) {
      case PoultryCategory.meat:
        return 'Chair';
      case PoultryCategory.layer:
        return 'Pondeuse';
    }
  }

  String get targetMetricLabel {
    switch (this) {
      case PoultryCategory.meat:
        return 'Poids cible (kg)';
      case PoultryCategory.layer:
        return 'Age de ponte (jours)';
    }
  }

  static PoultryCategory fromValue(String value) {
    return switch (value) {
      'layer' || 'pondeuse' => PoultryCategory.layer,
      _ => PoultryCategory.meat,
    };
  }

  String get value => switch (this) {
    PoultryCategory.meat => 'meat',
    PoultryCategory.layer => 'layer',
  };
}

extension LotExitReasonX on LotExitReason {
  String get label {
    switch (this) {
      case LotExitReason.slaughter:
        return 'Abattage';
      case LotExitReason.sale:
        return 'Vente';
      case LotExitReason.mortality:
        return 'Mortalite';
      case LotExitReason.transfer:
        return 'Transfert';
    }
  }
}

extension JournalEventTypeX on JournalEventType {
  String get label {
    switch (this) {
      case JournalEventType.entry:
        return 'Entree';
      case JournalEventType.dailyEntry:
        return 'Saisie';
      case JournalEventType.vaccination:
        return 'Vaccination';
      case JournalEventType.alert:
        return 'Alerte';
      case JournalEventType.closure:
        return 'Cloture';
    }
  }
}
