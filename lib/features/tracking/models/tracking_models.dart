import 'package:flutter/material.dart';

enum TrackingKind { broiler, layer }

class TrackingKindResolver {
  TrackingKindResolver._();

  static TrackingKind? resolve(String rawType) {
    final v = _norm(rawType);
    if (v.isEmpty) return null;

    if (_containsAny(v, const ['chair', 'broiler', 'poulet', 'poulets'])) {
      return TrackingKind.broiler;
    }
    if (_containsAny(v, const [
      'pondeuse',
      'pondeuses',
      'layer',
      'oeuf',
      'oeufs',
    ])) {
      return TrackingKind.layer;
    }
    return null;
  }

  static String label(TrackingKind kind) {
    switch (kind) {
      case TrackingKind.broiler:
        return 'Poules de chair';
      case TrackingKind.layer:
        return 'Poules pondeuses';
    }
  }

  static IconData icon(TrackingKind kind) {
    switch (kind) {
      case TrackingKind.broiler:
        return Icons.monitor_weight_rounded;
      case TrackingKind.layer:
        return Icons.egg_rounded;
    }
  }

  static bool _containsAny(String source, List<String> keys) {
    for (final key in keys) {
      if (source.contains(key)) return true;
    }
    return false;
  }

  static String _norm(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }
}

class TrackingEntry {
  final String id;
  final TrackingKind kind;
  final DateTime date;
  final String notes;
  final double? avgWeightKg;
  final double? feedKg;
  final int? eggs;
  final int? brokenEggs;
  final double? avgEggWeightG;
  final int mortality;
  final int remainingBirds;

  const TrackingEntry({
    required this.id,
    required this.kind,
    required this.date,
    required this.notes,
    required this.avgWeightKg,
    required this.feedKg,
    required this.eggs,
    required this.brokenEggs,
    required this.avgEggWeightG,
    required this.mortality,
    required this.remainingBirds,
  });

  Map<String, dynamic> toMap() => {
    'kind': kind.name,
    'date': date.toIso8601String(),
    'notes': notes,
    'avgWeightKg': avgWeightKg,
    'feedKg': feedKg,
    'eggs': eggs,
    'brokenEggs': brokenEggs,
    'avgEggWeightG': avgEggWeightG,
    'mortality': mortality,
    'remainingBirds': remainingBirds,
  };

  factory TrackingEntry.fromMap(String id, Map<String, dynamic> map) {
    final kindRaw = map['kind'] as String?;
    final kind = kindRaw == 'layer' ? TrackingKind.layer : TrackingKind.broiler;

    return TrackingEntry(
      id: id,
      kind: kind,
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      notes: map['notes']?.toString() ?? '',
      avgWeightKg: (map['avgWeightKg'] as num?)?.toDouble(),
      feedKg: (map['feedKg'] as num?)?.toDouble(),
      eggs: (map['eggs'] as num?)?.toInt(),
      brokenEggs: (map['brokenEggs'] as num?)?.toInt(),
      avgEggWeightG: (map['avgEggWeightG'] as num?)?.toDouble(),
      mortality: (map['mortality'] as num?)?.toInt() ?? 0,
      remainingBirds: (map['remainingBirds'] as num?)?.toInt() ?? 0,
    );
  }
}

class TrackingSummary {
  final String title;
  final String value;
  final String secondary;
  final String tertiary;

  const TrackingSummary({
    required this.title,
    required this.value,
    required this.secondary,
    required this.tertiary,
  });
}
