import 'package:cloud_firestore/cloud_firestore.dart';

class VaccinationPlan {
  final String id;
  final String lotId;
  final String lotIdentifier;
  final String buildingName;
  final String poultryTypeName;
  final String vaccineName;
  final String administrationRoute;
  final double dosePerSubject;
  final Timestamp plannedDate;
  final String status;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp? actualDate;
  final double? actualDosePerSubject;
  final int? vaccinatedSubjects;

  const VaccinationPlan({
    required this.id,
    required this.lotId,
    required this.lotIdentifier,
    required this.buildingName,
    required this.poultryTypeName,
    required this.vaccineName,
    required this.administrationRoute,
    required this.dosePerSubject,
    required this.plannedDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.actualDate,
    this.actualDosePerSubject,
    this.vaccinatedSubjects,
  });

  bool get isCompleted => status == 'completed';

  factory VaccinationPlan.fromMap(String id, Map<String, dynamic> map) {
    return VaccinationPlan(
      id: id,
      lotId: map['lotId'] as String? ?? '',
      lotIdentifier: map['lotIdentifier'] as String? ?? '',
      buildingName: map['buildingName'] as String? ?? '',
      poultryTypeName: map['poultryTypeName'] as String? ?? '',
      vaccineName: map['vaccineName'] as String? ?? '',
      administrationRoute: map['administrationRoute'] as String? ?? '',
      dosePerSubject: (map['dosePerSubject'] as num?)?.toDouble() ?? 0,
      plannedDate: map['plannedDate'] as Timestamp? ?? Timestamp.now(),
      status: map['status'] as String? ?? 'planned',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
      actualDate: map['actualDate'] as Timestamp?,
      actualDosePerSubject: (map['actualDosePerSubject'] as num?)?.toDouble(),
      vaccinatedSubjects: map['vaccinatedSubjects'] as int?,
    );
  }
}
