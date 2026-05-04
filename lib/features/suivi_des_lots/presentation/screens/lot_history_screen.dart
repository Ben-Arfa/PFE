import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../gestions_des_lots_des_volailles/domain/entities/flock_lot.dart';
import '../../../saisie_quotidienne/data/repositories/daily_entry_repository_impl.dart';
import '../../../saisie_quotidienne/data/services/daily_entry_service.dart';
import '../../../saisie_quotidienne/domain/entities/daily_entry.dart';
import '../../data/repositories/lot_traceability_repository_impl.dart';
import '../../data/services/lot_traceability_service.dart';
import '../../domain/entities/create_lot_history_event_input.dart';
import '../../domain/entities/lot_history_event.dart';

class LotHistoryScreen extends StatelessWidget {
  final FlockLot lot;

  LotHistoryScreen({super.key, required this.lot});

  final _eventsRepo = LotTraceabilityRepositoryImpl(LotTraceabilityService());
  final _entriesRepo = DailyEntryRepositoryImpl(DailyEntryService());

  bool get _isLayer {
    final name = lot.poultryTypeName.toLowerCase();
    return name.contains('ponde') || name.contains('pondeuse');
  }

  Future<void> _addEvent(BuildContext context) async {
    final typeCtrl = TextEditingController(text: 'vaccination');
    final titleCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ajouter un évènement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Type (vaccination, traitement, alerte, note)',
                ),
              ),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Détails'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result != true) return;

    await _eventsRepo.addEvent(
      CreateLotHistoryEventInput(
        lotId: lot.id,
        type: typeCtrl.text.trim().isEmpty ? 'note' : typeCtrl.text.trim(),
        title: titleCtrl.text.trim().isEmpty
            ? 'Évènement lot'
            : titleCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        eventAt: DateTime.now(),
      ),
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Évènement ajouté')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historique — ${lot.identifier}')),
      floatingActionButton: lot.isActive
          ? FloatingActionButton.extended(
              onPressed: () => _addEvent(context),
              icon: const Icon(Icons.add),
              label: const Text('Évènement'),
            )
          : null,
      body: StreamBuilder<List<DailyEntry>>(
        stream: _entriesRepo.watchEntriesForLot(lot.id),
        builder: (context, entriesSnapshot) {
          return StreamBuilder<List<LotHistoryEvent>>(
            stream: _eventsRepo.watchEvents(lot.id),
            builder: (context, eventsSnapshot) {
              if (entriesSnapshot.connectionState == ConnectionState.waiting ||
                  eventsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final entries = entriesSnapshot.data ?? const <DailyEntry>[];
              final events = eventsSnapshot.data ?? const <LotHistoryEvent>[];
              final timeline = <_TimelineRow>[
                _TimelineRow(
                  timestamp: lot.entryDate,
                  title: 'Entrée du lot',
                  subtitle:
                      '${lot.initialBirdCount} sujets - ${lot.buildingName}',
                  icon: Icons.login_rounded,
                ),
                ...entries.map(
                  (entry) => _TimelineRow(
                    timestamp: entry.date,
                    title: 'Saisie quotidienne',
                    subtitle: _isLayer
                        ? 'Morts ${entry.deathsToday} - Œufs ${entry.eggsToday ?? 0} - Aliment ${entry.feedKg} kg'
                        : 'Morts ${entry.deathsToday} - Poids ${entry.avgWeightKg ?? '-'} kg - Aliment ${entry.feedKg} kg',
                    icon: Icons.event_note_outlined,
                  ),
                ),
                ...events.map(
                  (event) => _TimelineRow(
                    timestamp: event.eventAt,
                    title: event.title,
                    subtitle: event.description,
                    icon: _iconForType(event.type),
                  ),
                ),
                if (lot.closedAt != null)
                  _TimelineRow(
                    timestamp: lot.closedAt!,
                    title: 'Clôture du lot',
                    subtitle: lot.closureReason ?? 'Lot clôturé',
                    icon: Icons.lock_outline,
                  ),
              ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

              if (timeline.isEmpty) {
                return const Center(
                  child: Text('Aucun historique disponible.'),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (lot.closedAt != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bilan de clôture',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sujets sortis: ${lot.closedSubjectsOut ?? '-'}',
                            ),
                            Text('Motif: ${lot.closureReason ?? '-'}'),
                            if (lot.finalAvgWeightKg != null)
                              Text(
                                'Poids moyen final: ${lot.finalAvgWeightKg!.toStringAsFixed(2)} kg',
                              ),
                            if (lot.totalEggProduction != null)
                              Text(
                                'Production totale d\'œufs: ${lot.totalEggProduction}',
                              ),
                            if (lot.closureSummary != null)
                              Text('Résumé: ${lot.closureSummary}'),
                          ],
                        ),
                      ),
                    ),
                  if (lot.closedAt != null) const SizedBox(height: 16),
                  const Text(
                    'Journal chronologique',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...timeline.map(
                    (item) => Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Icon(item.icon, size: 18)),
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.timestamp.toDate().toLocal().toIso8601String().split('T').first}\n${item.subtitle}',
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Icons.vaccines_outlined;
      case 'vaccination_plan':
        return Icons.event_available_outlined;
      case 'traitement':
        return Icons.medication_outlined;
      case 'alerte':
        return Icons.warning_amber_outlined;
      case 'closure':
        return Icons.lock_outline;
      default:
        return Icons.note_alt_outlined;
    }
  }
}

class _TimelineRow {
  final Timestamp timestamp;
  final String title;
  final String subtitle;
  final IconData icon;

  _TimelineRow({
    required this.timestamp,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
