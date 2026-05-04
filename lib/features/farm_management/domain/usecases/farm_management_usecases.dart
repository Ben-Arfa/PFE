import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiwo/features/gestion_des_types_des_volailles/data/repositories/poultry_type_repository_impl.dart';
import 'package:kiwo/features/gestion_des_types_des_volailles/data/services/poultry_type_service.dart';
import 'package:kiwo/features/gestions_des_batiments/data/repositories/building_repository_impl.dart';
import 'package:kiwo/features/gestions_des_batiments/data/services/building_service.dart';
import 'package:kiwo/features/gestions_des_lots_des_volailles/data/repositories/lot_repository_impl.dart';
import 'package:kiwo/features/gestions_des_lots_des_volailles/data/services/lot_service.dart';
import 'package:kiwo/features/saisie_quotidienne/data/repositories/daily_entry_repository_impl.dart';
import 'package:kiwo/features/saisie_quotidienne/data/services/daily_entry_service.dart';
import 'package:kiwo/features/suivi_des_lots/data/repositories/lot_traceability_repository_impl.dart';
import 'package:kiwo/features/suivi_des_lots/data/services/lot_traceability_service.dart';

import '../../../gestion_des_types_des_volailles/domain/entities/poultry_type.dart'
    as repo_type;
import '../../../gestion_des_types_des_volailles/domain/entities/poultry_type_input.dart'
    as repo_type;
import '../../../gestions_des_batiments/domain/entities/building.dart'
    as repo_building;
import '../../../gestions_des_batiments/domain/entities/building_input.dart'
    as repo_building;
import '../../../gestions_des_lots_des_volailles/domain/entities/flock_lot.dart'
    as repo_lot;
import '../../../gestions_des_lots_des_volailles/domain/entities/create_lot_input.dart'
    as repo_lot;
import '../../../gestions_des_lots_des_volailles/domain/entities/close_lot_input.dart'
    as repo_lot;
import '../../../saisie_quotidienne/domain/entities/daily_entry.dart'
    as repo_daily;
import '../../../saisie_quotidienne/domain/inputs/create_daily_entry_input.dart'
    as repo_daily;
import '../../../suivi_des_lots/domain/entities/create_lot_history_event_input.dart'
    as repo_history;
import '../../../suivi_des_lots/domain/entities/lot_history_event.dart'
    as repo_history;
import '../entities/farm_management_inputs.dart';
import '../entities/farm_management_models.dart';

class FarmManagementUseCases {
  final _typeRepo = PoultryTypeRepositoryImpl(PoultryTypeService());
  final _buildingRepo = BuildingRepositoryImpl(BuildingService());
  final _lotRepo = LotRepositoryImpl(LotService());
  final _dailyRepo = DailyEntryRepositoryImpl(DailyEntryService());
  final _traceRepo = LotTraceabilityRepositoryImpl(LotTraceabilityService());

  Stream<List<PoultryType>> watchPoultryTypes() =>
      _typeRepo.watchAll().map((items) => items.map(_mapPoultryType).toList());

  Stream<List<Building>> watchBuildings() => _buildingRepo.watchBuildings().map(
    (items) => items.map(_mapBuilding).toList(),
  );

  Stream<List<Building>> watchAvailableBuildings() => _buildingRepo
      .watchAvailableBuildings()
      .map((items) => items.map(_mapBuilding).toList());

  Stream<List<FlockLot>> watchLots({LotStatus? status}) {
    return _lotRepo.watchLots().asyncMap((lots) async {
      final types = await _typeRepo.watchAll().first;
      final mapped = lots.map((lot) => _mapLot(lot, types)).toList();
      if (status == LotStatus.active) {
        return mapped.where((lot) => lot.isActive).toList();
      }
      return mapped;
    });
  }

  Stream<List<DailyEntry>> watchDailyEntries(String lotId) => _dailyRepo
      .watchEntriesForLot(lotId)
      .map((items) => items.map(_mapDailyEntry).toList());

  Stream<List<LotJournalEvent>> watchLotJournal(String lotId) => _traceRepo
      .watchEvents(lotId)
      .map((items) => items.map(_mapJournalEvent).toList());

  Future<void> createPoultryType(PoultryTypeInput input) {
    return _typeRepo.create(
      repo_type.PoultryTypeInput(
        name: input.name,
        category: input.category.value,
        targetTempMin: input.targetTempMin,
        targetTempMax: input.targetTempMax,
        targetHumidityMin: input.targetHumidityMin,
        targetHumidityMax: input.targetHumidityMax,
        recommendedDensity: input.recommendedDensity,
        recommendedLightHours: input.recommendedLightHours,
        typicalDurationDays: input.typicalDurationDays,
        targetWeightKg: input.category == PoultryCategory.meat
            ? input.targetValue
            : null,
        layStartAgeDays: input.category == PoultryCategory.layer
            ? input.targetValue.toInt()
            : null,
      ),
    );
  }

  Future<void> updatePoultryType({
    required String poultryTypeId,
    required PoultryTypeInput input,
  }) {
    return _typeRepo.update(
      poultryTypeId,
      repo_type.PoultryTypeInput(
        name: input.name,
        category: input.category.value,
        targetTempMin: input.targetTempMin,
        targetTempMax: input.targetTempMax,
        targetHumidityMin: input.targetHumidityMin,
        targetHumidityMax: input.targetHumidityMax,
        recommendedDensity: input.recommendedDensity,
        recommendedLightHours: input.recommendedLightHours,
        typicalDurationDays: input.typicalDurationDays,
        targetWeightKg: input.category == PoultryCategory.meat
            ? input.targetValue
            : null,
        layStartAgeDays: input.category == PoultryCategory.layer
            ? input.targetValue.toInt()
            : null,
      ),
    );
  }

  Future<void> deletePoultryType(String id) => _typeRepo.delete(id);

  Future<void> createBuilding(BuildingInput input) {
    return _buildingRepo.createBuilding(
      repo_building.BuildingInput(
        name: input.name,
        areaM2: input.areaM2,
        capacityMax: input.capacityMax,
        status: repo_building.BuildingStatusX.fromValue(input.status.name),
      ),
    );
  }

  Future<void> updateBuilding({
    required String buildingId,
    required BuildingInput input,
  }) {
    return _buildingRepo.updateBuilding(
      buildingId,
      repo_building.BuildingInput(
        name: input.name,
        areaM2: input.areaM2,
        capacityMax: input.capacityMax,
        status: repo_building.BuildingStatusX.fromValue(input.status.name),
      ),
    );
  }

  Future<void> deleteBuilding(String id) => _buildingRepo.deleteBuilding(id);

  Future<void> createLot(CreateLotInput input) async {
    final types = await _typeRepo.watchAll().first;
    final buildings = await _buildingRepo.watchAvailableBuildings().first;
    final selectedType = types.firstWhere(
      (item) => item.id == input.poultryTypeId,
    );
    final selectedBuilding = buildings.firstWhere(
      (item) => item.id == input.buildingId,
    );
    await _lotRepo.createLot(
      repo_lot.CreateLotInput(
        identifier: input.identifier,
        buildingId: input.buildingId,
        buildingName: selectedBuilding.name,
        poultryTypeId: input.poultryTypeId,
        poultryTypeName: selectedType.name,
        entryDate: input.entryDate,
        initialBirdCount: input.initialBirdCount,
        provenance: input.supplier,
      ),
    );
  }

  Future<void> closeLot(CloseLotInput input) async {
    final lots = await _lotRepo.watchLots().first;
    final lot = lots.firstWhere((item) => item.id == input.lotId);
    await _lotRepo.closeLot(
      repo_lot.CloseLotInput(
        lotId: input.lotId,
        buildingId: lot.buildingId,
        closureDate: input.exitDate,
        subjectsOut: input.finalBirdCount,
        closureReason: input.exitReason?.label ?? 'Cloture',
        finalAvgWeightKg: input.averageFinalWeightKg,
        totalEggProduction: input.totalEggProduction,
      ),
    );
  }

  Future<void> createDailyEntry(CreateDailyEntryInput input) {
    return _dailyRepo.createEntry(
      repo_daily.CreateDailyEntryInput(
        lotId: input.lotId,
        date: input.entryDate,
        deathsToday: input.dailyMortality,
        eggsToday: input.eggCount,
        avgWeightKg: input.averageWeightKg,
        feedKg: input.feedKg,
        waterL: input.waterLiters,
        observations: input.notes,
      ),
    );
  }

  Future<void> addJournalEvent(AddJournalNoteInput input) {
    return _traceRepo.addEvent(
      repo_history.CreateLotHistoryEventInput(
        lotId: input.lotId,
        type: input.type.name,
        title: input.title,
        description: input.description,
        eventAt: input.occurredAt,
      ),
    );
  }

  static PoultryType _mapPoultryType(repo_type.PoultryType item) {
    final category = PoultryCategoryX.fromValue(item.category);
    return PoultryType(
      id: item.id,
      name: item.name,
      category: category,
      targetTempMin: item.targetTempMin,
      targetTempMax: item.targetTempMax,
      targetHumidityMin: item.targetHumidityMin,
      targetHumidityMax: item.targetHumidityMax,
      recommendedDensity: item.recommendedDensity,
      recommendedLightHours: item.recommendedLightHours,
      typicalDurationDays: item.typicalDurationDays,
      targetValue: item.targetWeightKg ?? item.layStartAgeDays?.toDouble() ?? 0,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  static Building _mapBuilding(repo_building.Building item) {
    return Building(
      id: item.id,
      name: item.name,
      areaM2: item.areaM2,
      capacityMax: item.capacityMax,
      status: BuildingStatus.values.firstWhere(
        (value) => value.name == item.status.name,
        orElse: () => BuildingStatus.empty,
      ),
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  static FlockLot _mapLot(
    repo_lot.FlockLot item,
    List<repo_type.PoultryType> types,
  ) {
    final mappedType = types.firstWhere(
      (type) => type.id == item.poultryTypeId,
      orElse: () => repo_type.PoultryType(
        id: item.poultryTypeId,
        name: item.poultryTypeName,
        category: 'meat',
        targetTempMin: 0,
        targetTempMax: 0,
        targetHumidityMin: 0,
        targetHumidityMax: 0,
        recommendedDensity: 0,
        recommendedLightHours: 0,
        typicalDurationDays: 0,
        createdAt: item.createdAt,
        updatedAt: item.createdAt,
      ),
    );
    return FlockLot(
      id: item.id,
      identifier: item.identifier,
      buildingId: item.buildingId,
      buildingName: item.buildingName,
      poultryTypeId: item.poultryTypeId,
      poultryTypeName: item.poultryTypeName,
      category: PoultryCategoryX.fromValue(mappedType.category),
      entryDate: item.entryDate.toDate(),
      initialBirdCount: item.initialBirdCount,
      currentBirdCount: item.currentBirdCount,
      totalDeaths: item.initialBirdCount - item.currentBirdCount,
      isActive: item.isActive,
      supplier: item.provenance,
      createdAt: item.createdAt,
      summary: item.closureSummary == null
          ? null
          : LotClosureSummary(
              exitDate: (item.closureSummary!['exitDate'] as Timestamp?)
                  ?.toDate(),
              finalBirdCount: item.closureSummary!['finalBirdCount'] as int?,
              cumulativeMortalityRate:
                  (item.closureSummary!['cumulativeMortalityRate'] as num?)
                      ?.toDouble(),
              averageFinalWeightKg:
                  (item.closureSummary!['averageFinalWeightKg'] as num?)
                      ?.toDouble(),
              totalEggProduction:
                  item.closureSummary!['totalEggProduction'] as int?,
            ),
    );
  }

  static DailyEntry _mapDailyEntry(repo_daily.DailyEntry item) {
    return DailyEntry(
      id: item.id,
      lotId: item.lotId,
      entryDate: item.date.toDate(),
      dailyMortality: item.deathsToday,
      cumulativeMortalityRate: 0,
      feedKg: item.feedKg,
      waterLiters: item.waterL,
      notes: item.observations ?? '',
      averageWeightKg: item.avgWeightKg,
      dailyWeightGainG: null,
      feedConversionRatio: null,
      eggCount: item.eggsToday,
      layRate: null,
      peakLayRate: null,
    );
  }

  static LotJournalEvent _mapJournalEvent(repo_history.LotHistoryEvent item) {
    final type = switch (item.type) {
      'entry' => JournalEventType.entry,
      'dailyEntry' => JournalEventType.dailyEntry,
      'vaccination' => JournalEventType.vaccination,
      'alert' => JournalEventType.alert,
      'closure' => JournalEventType.closure,
      _ => JournalEventType.entry,
    };
    return LotJournalEvent(
      id: item.id,
      lotId: item.lotId,
      type: type,
      title: item.title,
      description: item.description,
      occurredAt: item.eventAt.toDate(),
    );
  }
}

enum LotStatus { active, closed }
