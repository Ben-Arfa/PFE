class CloseLotInput {
  final String lotId;
  final String buildingId;
  final DateTime closureDate;
  final int subjectsOut;
  final String closureReason;
  final double? finalAvgWeightKg;
  final int? totalEggProduction;

  const CloseLotInput({
    required this.lotId,
    required this.buildingId,
    required this.closureDate,
    required this.subjectsOut,
    required this.closureReason,
    this.finalAvgWeightKg,
    this.totalEggProduction,
  });
}
