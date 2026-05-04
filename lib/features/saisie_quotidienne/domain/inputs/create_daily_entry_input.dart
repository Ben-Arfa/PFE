class CreateDailyEntryInput {
  final String lotId;
  final DateTime date;
  final int deathsToday;
  final int? eggsToday;
  final double? avgWeightKg;
  final double feedKg;
  final double waterL;
  final String? observations;

  CreateDailyEntryInput({
    required this.lotId,
    required this.date,
    required this.deathsToday,
    this.eggsToday,
    this.avgWeightKg,
    required this.feedKg,
    required this.waterL,
    this.observations,
  });
}
