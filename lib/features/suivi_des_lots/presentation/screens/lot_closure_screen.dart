import 'package:flutter/material.dart';

import '../../../gestions_des_lots_des_volailles/data/repositories/lot_repository_impl.dart';
import '../../../gestions_des_lots_des_volailles/data/services/lot_service.dart';
import '../../../gestions_des_lots_des_volailles/domain/entities/close_lot_input.dart';
import '../../../gestions_des_lots_des_volailles/domain/entities/flock_lot.dart';
import '../../../saisie_quotidienne/data/repositories/daily_entry_repository_impl.dart';
import '../../../saisie_quotidienne/data/services/daily_entry_service.dart';
import '../../../saisie_quotidienne/domain/entities/daily_entry.dart';
import '../../domain/entities/lot_closure_summary.dart';

class LotClosureScreen extends StatefulWidget {
  final FlockLot lot;

  const LotClosureScreen({super.key, required this.lot});

  @override
  State<LotClosureScreen> createState() => _LotClosureScreenState();
}

class _LotClosureScreenState extends State<LotClosureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectsOutCtrl = TextEditingController();
  final _finalWeightCtrl = TextEditingController();
  final _eggProductionCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  DateTime _closureDate = DateTime.now();

  final _lotRepo = LotRepositoryImpl(LotService());
  final _entryRepo = DailyEntryRepositoryImpl(DailyEntryService());

  bool get _isLayer {
    final name = widget.lot.poultryTypeName.toLowerCase();
    return name.contains('ponde') || name.contains('pondeuse');
  }

  @override
  void initState() {
    super.initState();
    _subjectsOutCtrl.text = widget.lot.currentBirdCount.toString();
  }

  @override
  void dispose() {
    _subjectsOutCtrl.dispose();
    _finalWeightCtrl.dispose();
    _eggProductionCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _closureDate,
      firstDate: widget.lot.entryDate.toDate(),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _closureDate = picked);
  }

  LotClosureSummary _buildSummary(List<DailyEntry> entries) {
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));

    final totalDeaths = sorted.fold<int>(
      0,
      (sum, entry) => sum + entry.deathsToday,
    );
    final mortalityPct = widget.lot.initialBirdCount > 0
        ? (totalDeaths / widget.lot.initialBirdCount) * 100
        : 0.0;
    final cycleDays =
        _closureDate.difference(widget.lot.entryDate.toDate()).inDays + 1;

    if (_isLayer) {
      final totalEggs = sorted.fold<int>(
        0,
        (sum, entry) => sum + (entry.eggsToday ?? 0),
      );
      var totalBirdDays = 0;
      var cumulativeDeaths = 0;
      var peakEggs = 0;
      for (final entry in sorted) {
        final alive = (widget.lot.initialBirdCount - cumulativeDeaths).clamp(
          0,
          widget.lot.initialBirdCount,
        );
        totalBirdDays += alive;
        cumulativeDeaths += entry.deathsToday;
        final eggs = entry.eggsToday ?? 0;
        if (eggs > peakEggs) peakEggs = eggs;
      }

      final averageLayingRate = totalBirdDays > 0
          ? (totalEggs / totalBirdDays) * 100
          : 0.0;

      return LotClosureSummary(
        isLayer: true,
        cycleDays: cycleDays,
        totalDeaths: totalDeaths,
        mortalityPct: mortalityPct,
        averageLayingRate: averageLayingRate,
        peakEggs: peakEggs,
        subjectsOut:
            int.tryParse(_subjectsOutCtrl.text) ?? widget.lot.currentBirdCount,
        totalEggProduction: int.tryParse(_eggProductionCtrl.text) ?? totalEggs,
        closureReason: _reasonCtrl.text,
      );
    }

    final weights = sorted
        .map((entry) => entry.avgWeightKg)
        .whereType<double>()
        .toList();
    final totalFeed = sorted.fold<double>(
      0,
      (sum, entry) => sum + entry.feedKg,
    );
    final firstWeight = weights.isNotEmpty ? weights.first : 0.0;
    final lastWeight = weights.isNotEmpty ? weights.last : null;
    final gainPerBird = lastWeight != null ? (lastWeight - firstWeight) : null;
    final gmq = gainPerBird != null && cycleDays > 0
        ? gainPerBird / cycleDays
        : null;
    final subjectsOut =
        int.tryParse(_subjectsOutCtrl.text) ?? widget.lot.currentBirdCount;
    final ic = (gainPerBird != null && gainPerBird > 0 && subjectsOut > 0)
        ? totalFeed / (gainPerBird * subjectsOut)
        : null;

    return LotClosureSummary(
      isLayer: false,
      cycleDays: cycleDays,
      totalDeaths: totalDeaths,
      mortalityPct: mortalityPct,
      gmq: gmq,
      ic: ic,
      finalAvgWeightKg: double.tryParse(_finalWeightCtrl.text) ?? lastWeight,
      subjectsOut: subjectsOut,
      closureReason: _reasonCtrl.text,
    );
  }

  Future<void> _submit(List<DailyEntry> entries) async {
    if (!_formKey.currentState!.validate()) return;
    final summary = _buildSummary(entries);

    try {
      await _lotRepo.closeLot(
        CloseLotInput(
          lotId: widget.lot.id,
          buildingId: widget.lot.buildingId,
          closureDate: _closureDate,
          subjectsOut: summary.subjectsOut,
          closureReason: summary.closureReason,
          finalAvgWeightKg: summary.finalAvgWeightKg,
          totalEggProduction: summary.totalEggProduction,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lot clôturé avec succès')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clôture — ${widget.lot.identifier}')),
      body: StreamBuilder<List<DailyEntry>>(
        stream: _entryRepo.watchEntriesForLot(widget.lot.id),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const <DailyEntry>[];
          final summary = _buildSummary(entries);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLayer
                                ? 'Clôture d’un lot Pondeuse'
                                : 'Clôture d’un lot Chair',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Le bilan est calculé automatiquement à partir des saisies quotidiennes.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Date de sortie: ${_closureDate.toIso8601String().split('T').first}',
                    ),
                    trailing: TextButton(
                      onPressed: _pickDate,
                      child: const Text('Changer'),
                    ),
                  ),
                  TextFormField(
                    controller: _subjectsOutCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de sujets sortis',
                    ),
                    validator: (value) => int.tryParse(value ?? '') == null
                        ? 'Entrez un nombre valide'
                        : null,
                  ),
                  if (_isLayer)
                    TextFormField(
                      controller: _eggProductionCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Production totale d\'œufs',
                      ),
                      validator: (value) => int.tryParse(value ?? '') == null
                          ? 'Entrez un nombre valide'
                          : null,
                    )
                  else
                    TextFormField(
                      controller: _finalWeightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Poids moyen final (kg)',
                      ),
                      validator: (value) =>
                          value != null &&
                              value.isNotEmpty &&
                              double.tryParse(value) == null
                          ? 'Entrez un poids valide'
                          : null,
                    ),
                  TextFormField(
                    controller: _reasonCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Motif de sortie',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Motif requis'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bilan automatique'),
                          const SizedBox(height: 8),
                          Text('Durée du cycle: ${summary.cycleDays} jours'),
                          Text(
                            'Mortalité totale: ${summary.mortalityPct.toStringAsFixed(2)}%',
                          ),
                          if (summary.gmq != null)
                            Text(
                              'GMQ: ${summary.gmq!.toStringAsFixed(3)} kg/j',
                            ),
                          if (summary.ic != null)
                            Text(
                              'IC estimé: ${summary.ic!.toStringAsFixed(2)}',
                            ),
                          if (summary.averageLayingRate != null)
                            Text(
                              'Taux de ponte moyen: ${summary.averageLayingRate!.toStringAsFixed(2)}%',
                            ),
                          if (summary.peakEggs != null)
                            Text('Pic de production: ${summary.peakEggs} œufs'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _submit(entries),
                    child: const Text('Clôturer le lot'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
