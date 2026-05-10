import 'package:flutter/material.dart';
import '../../../saisie_quotidienne/data/repositories/daily_entry_repository_impl.dart';
import '../../../saisie_quotidienne/data/services/daily_entry_service.dart';
import '../../../saisie_quotidienne/domain/entities/daily_entry.dart';
import '../../../saisie_quotidienne/presentation/widgets/sparkline.dart';
import '../../../saisie_quotidienne/presentation/screens/daily_entry_form_screen.dart';
import '../../../gestions_des_lots_des_volailles/domain/entities/flock_lot.dart';

class DailyEntriesScreen extends StatelessWidget {
  final FlockLot lot;

  DailyEntriesScreen({super.key, required this.lot});

  final _repo = DailyEntryRepositoryImpl(DailyEntryService());

  bool _isLayer() {
    final name = lot.poultryTypeName.toLowerCase();
    return name.contains('ponde') || name.contains('pondeuse');
  }

  @override
  Widget build(BuildContext context) {
    final isLayer = _isLayer();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DailyEntryFormScreen(lot: lot)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Hero header matching TypesScreen
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5DB83D), Color(0xFF8FD14E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5DB83D).withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_calendar_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Saisies — ${lot.identifier}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${lot.poultryTypeName} · ${lot.buildingName}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<List<DailyEntry>>(
                stream: _repo.watchEntriesForLot(lot.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }
                  final entries = snapshot.data ?? <DailyEntry>[];

                  // compute KPI lists
                  final deaths = entries
                      .map((e) => e.deathsToday.toDouble())
                      .toList();
                  final weights = entries
                      .map((e) => e.avgWeightKg ?? double.nan)
                      .where((v) => !v.isNaN)
                      .toList();
                  final eggs = entries
                      .map((e) => (e.eggsToday ?? 0).toDouble())
                      .toList();

                  final cumulativeDeaths = entries.fold<int>(
                    0,
                    (p, e) => p + e.deathsToday,
                  );
                  final cumulativeMortalityPct = lot.initialBirdCount > 0
                      ? (cumulativeDeaths / lot.initialBirdCount) * 100
                      : 0.0;

                  double? latestAvgWeight = weights.isNotEmpty
                      ? weights.last
                      : null;
                  double? previousAvgWeight = weights.length > 1
                      ? weights[weights.length - 2]
                      : null;
                  double? gmq;
                  if (latestAvgWeight != null && previousAvgWeight != null) {
                    // fallback: assume 1 day between entries for simple GMQ
                    gmq = (latestAvgWeight - previousAvgWeight);
                  }

                  double? eggRateToday =
                      entries.isNotEmpty && lot.currentBirdCount > 0
                      ? (entries.last.eggsToday ?? 0) /
                            lot.currentBirdCount *
                            100
                      : null;

                  final peakEggs = eggs.isNotEmpty
                      ? eggs.reduce((a, b) => a > b ? a : b)
                      : 0.0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Résumé',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            Chip(
                              label: Text(
                                'Mortalité cumulée: ${cumulativeMortalityPct.toStringAsFixed(2)}%',
                              ),
                            ),
                            if (gmq != null)
                              Chip(
                                label: Text(
                                  'GMQ: ${gmq.toStringAsFixed(3)} kg/j',
                                ),
                              ),
                            if (eggRateToday != null)
                              Chip(
                                label: Text(
                                  'Taux ponte: ${eggRateToday.toStringAsFixed(1)}%',
                                ),
                              ),
                            if (peakEggs > 0)
                              Chip(
                                label: Text(
                                  'Pic production: ${peakEggs.toInt()} oeufs',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Graphiques',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Mortalité (jours)'),
                                Sparkline(values: deaths, color: Colors.red),
                                const SizedBox(height: 12),
                                if (!isLayer) ...[
                                  const Text('Poids moyen (kg)'),
                                  Sparkline(
                                    values: weights,
                                    color: Colors.blue,
                                  ),
                                ] else ...[
                                  const Text('Taux de ponte (%)'),
                                  Sparkline(
                                    values: eggs
                                        .map(
                                          (e) => lot.currentBirdCount > 0
                                              ? (e.toDouble() /
                                                        lot.currentBirdCount) *
                                                    100
                                              : 0.0,
                                        )
                                        .toList(),
                                    color: Colors.orange,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Historique',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...entries.reversed.map(
                          (e) => Card(
                            child: ListTile(
                              title: Text(
                                e.date
                                    .toDate()
                                    .toLocal()
                                    .toIso8601String()
                                    .split('T')
                                    .first,
                              ),
                              subtitle: isLayer
                                  ? Text(
                                      'Morts: ${e.deathsToday} · Oeufs: ${e.eggsToday ?? 0} · Aliments: ${e.feedKg} kg',
                                    )
                                  : Text(
                                      'Morts: ${e.deathsToday} · Poids: ${e.avgWeightKg ?? '-'} kg · Aliments: ${e.feedKg} kg',
                                    ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await _repo.deleteEntry(lot.id, e.id);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
