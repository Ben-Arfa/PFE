import 'building.dart';

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

  Map<String, dynamic> toMap() => {
    'name': name,
    'areaM2': areaM2,
    'capacityMax': capacityMax,
    'status': status.value,
  };
}
