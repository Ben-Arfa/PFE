class LotClosureSummary {
  final bool isLayer;
  final int cycleDays;
  final int totalDeaths;
  final double mortalityPct;
  final double? gmq;
  final double? ic;
  final double? averageLayingRate;
  final int? peakEggs;
  final double? finalAvgWeightKg;
  final int subjectsOut;
  final int? totalEggProduction;
  final String closureReason;

  const LotClosureSummary({
    required this.isLayer,
    required this.cycleDays,
    required this.totalDeaths,
    required this.mortalityPct,
    this.gmq,
    this.ic,
    this.averageLayingRate,
    this.peakEggs,
    this.finalAvgWeightKg,
    required this.subjectsOut,
    this.totalEggProduction,
    required this.closureReason,
  });

  Map<String, dynamic> toMap() => {
    'isLayer': isLayer,
    'cycleDays': cycleDays,
    'totalDeaths': totalDeaths,
    'mortalityPct': mortalityPct,
    'gmq': gmq,
    'ic': ic,
    'averageLayingRate': averageLayingRate,
    'peakEggs': peakEggs,
    'finalAvgWeightKg': finalAvgWeightKg,
    'subjectsOut': subjectsOut,
    'totalEggProduction': totalEggProduction,
    'closureReason': closureReason,
  };
}
