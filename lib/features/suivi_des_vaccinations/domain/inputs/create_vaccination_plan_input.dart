class CreateVaccinationPlanInput {
  final String lotId;
  final String lotIdentifier;
  final String buildingName;
  final String poultryTypeName;
  final DateTime plannedDate;
  final String vaccineName;
  final String administrationRoute;
  final double dosePerSubject;

  const CreateVaccinationPlanInput({
    required this.lotId,
    required this.lotIdentifier,
    required this.buildingName,
    required this.poultryTypeName,
    required this.plannedDate,
    required this.vaccineName,
    required this.administrationRoute,
    required this.dosePerSubject,
  });
}
