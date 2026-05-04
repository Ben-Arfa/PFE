class CreateLotInput {
  final String identifier;
  final String buildingId;
  final String buildingName;
  final String poultryTypeId;
  final String poultryTypeName;
  final DateTime entryDate;
  final int initialBirdCount;
  final String provenance;

  const CreateLotInput({
    required this.identifier,
    required this.buildingId,
    required this.buildingName,
    required this.poultryTypeId,
    required this.poultryTypeName,
    required this.entryDate,
    required this.initialBirdCount,
    required this.provenance,
  });
}
