class RecordVaccinationInput {
  final String lotId;
  final String planId;
  final DateTime actualDate;
  final double actualDosePerSubject;
  final int vaccinatedSubjects;

  const RecordVaccinationInput({
    required this.lotId,
    required this.planId,
    required this.actualDate,
    required this.actualDosePerSubject,
    required this.vaccinatedSubjects,
  });
}
