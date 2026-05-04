class VaccinationNotificationService {
  VaccinationNotificationService._();

  static final instance = VaccinationNotificationService._();

  Future<void> init() async {}

  Future<void> schedulePlanReminders({
    required String planId,
    required String lotIdentifier,
    required String vaccineName,
    required String administrationRoute,
    required DateTime plannedDate,
    required double dosePerSubject,
  }) async {
    await init();
    // Placeholder: brancher ici un backend FCM / Cloud Functions si tu veux de vrais push.
  }

  Future<void> cancelPlanReminders(String planId) async {
    await init();
  }
}
