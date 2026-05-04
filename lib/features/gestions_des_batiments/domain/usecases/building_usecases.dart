import '../entities/building.dart';
import '../entities/building_input.dart';
import '../repositories/building_repository.dart';

class BuildingUseCases {
  final BuildingRepository repository;

  BuildingUseCases(this.repository);

  Stream<List<Building>> watchBuildings() => repository.watchBuildings();

  Stream<List<Building>> watchAvailableBuildings() =>
      repository.watchAvailableBuildings();

  Future<void> createBuilding(BuildingInput input) =>
      repository.createBuilding(input);

  Future<void> updateBuilding(String id, BuildingInput input) =>
      repository.updateBuilding(id, input);

  Future<void> deleteBuilding(String id) => repository.deleteBuilding(id);
}
