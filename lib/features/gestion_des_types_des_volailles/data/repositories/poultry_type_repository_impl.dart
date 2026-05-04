import '../../domain/entities/poultry_type.dart';
import '../../domain/entities/poultry_type_input.dart';
import '../../domain/repositories/poultry_type_repository.dart';
import '../services/poultry_type_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PoultryTypeRepositoryImpl implements PoultryTypeRepository {
  final PoultryTypeService _service;

  PoultryTypeRepositoryImpl(this._service);

  @override
  Future<void> create(PoultryTypeInput input) => _service.createType(input);

  @override
  Stream<List<PoultryType>> watchAll() {
    return _service.watchAllRaw().map(
      (raw) => raw.map((m) {
        return PoultryType(
          id: m['id'] as String,
          name: (m['name'] ?? '') as String,
          category: (m['category'] ?? 'chair') as String,
          targetTempMin: (m['targetTempMin'] ?? 0).toDouble(),
          targetTempMax: (m['targetTempMax'] ?? 0).toDouble(),
          targetHumidityMin: (m['targetHumidityMin'] ?? 0).toDouble(),
          targetHumidityMax: (m['targetHumidityMax'] ?? 0).toDouble(),
          recommendedDensity: (m['recommendedDensity'] ?? 0).toDouble(),
          recommendedLightHours: (m['recommendedLightHours'] ?? 0).toDouble(),
          typicalDurationDays: (m['typicalDurationDays'] ?? 0) as int,
          targetWeightKg: m['targetWeightKg'] != null
              ? (m['targetWeightKg'] as num).toDouble()
              : null,
          layStartAgeDays: m['layStartAgeDays'] as int?,
          createdAt: m['createdAt'] as Timestamp? ?? Timestamp.now(),
          updatedAt: m['updatedAt'] as Timestamp? ?? Timestamp.now(),
        );
      }).toList(),
    );
  }

  @override
  Future<void> update(String id, PoultryTypeInput input) =>
      _service.updateType(id, input);

  @override
  Future<void> delete(String id) => _service.deleteType(id);
}
