class PoultryTypeInput {
  final String name;
  final String category; // 'chair' or 'pondeuse'
  final double targetTempMin;
  final double targetTempMax;
  final double targetHumidityMin;
  final double targetHumidityMax;
  final double recommendedDensity;
  final double recommendedLightHours;
  final int typicalDurationDays;
  final double? targetWeightKg;
  final int? layStartAgeDays;

  PoultryTypeInput({
    required this.name,
    required this.category,
    required this.targetTempMin,
    required this.targetTempMax,
    required this.targetHumidityMin,
    required this.targetHumidityMax,
    required this.recommendedDensity,
    required this.recommendedLightHours,
    required this.typicalDurationDays,
    this.targetWeightKg,
    this.layStartAgeDays,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    'targetTempMin': targetTempMin,
    'targetTempMax': targetTempMax,
    'targetHumidityMin': targetHumidityMin,
    'targetHumidityMax': targetHumidityMax,
    'recommendedDensity': recommendedDensity,
    'recommendedLightHours': recommendedLightHours,
    'typicalDurationDays': typicalDurationDays,
    'targetWeightKg': targetWeightKg,
    'layStartAgeDays': layStartAgeDays,
  };
}
