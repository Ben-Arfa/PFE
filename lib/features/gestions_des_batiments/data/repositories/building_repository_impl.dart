import '../../domain/entities/building.dart';
import '../../domain/entities/building_input.dart';
import '../../domain/repositories/building_repository.dart';
import '../services/building_service.dart';

class BuildingRepositoryImpl implements BuildingRepository {
  final BuildingService _service;

  BuildingRepositoryImpl(this._service);

  @override
  Future<void> createBuilding(BuildingInput input) =>
      _service.createBuilding(input);

  @override
  Future<void> deleteBuilding(String id) => _service.deleteBuilding(id);

  @override
  Stream<List<Building>> watchAvailableBuildings() =>
      _service.watchAvailableBuildings();

  @override
  Stream<List<Building>> watchBuildings() => _service.watchBuildings();

  @override
  Future<void> updateBuilding(String id, BuildingInput input) =>
      _service.updateBuilding(id, input);
}
