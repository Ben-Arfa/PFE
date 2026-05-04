import '../entities/building.dart';
import '../entities/building_input.dart';

abstract class BuildingRepository {
  Stream<List<Building>> watchBuildings();
  Stream<List<Building>> watchAvailableBuildings();
  Future<void> createBuilding(BuildingInput input);
  Future<void> updateBuilding(String id, BuildingInput input);
  Future<void> deleteBuilding(String id);
}
