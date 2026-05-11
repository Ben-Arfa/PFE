import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../gestions_des_lots_des_volailles/domain/entities/flock_lot.dart';
import '../../../saisie_quotidienne/data/repositories/daily_entry_repository_impl.dart';
import '../../../saisie_quotidienne/data/services/daily_entry_service.dart';
import '../../../saisie_quotidienne/domain/entities/daily_entry.dart';
import '../../data/repositories/lot_traceability_repository_impl.dart';
import '../../data/services/lot_traceability_service.dart';
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

  Future<void> _downloadLotReportPdf(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Génération du PDF en cours...')),
    );

    try {
      final entries = await _entriesRepo.watchEntriesForLot(lot.id).first;
      final events = await _eventsRepo.watchEvents(lot.id).first;
      final pdfBytes = await _buildLotReportPdf(entries, events);
      final fileName = 'bilan_lot_${_sanitizeFileName(lot.identifier)}.pdf';
      final directory = await _resolvePdfDirectory();
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(pdfBytes, flush: true);

      await OpenFilex.open(file.path);

      messenger.showSnackBar(
        SnackBar(
          content: Text('PDF enregistré dans ${file.path}'),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Impossible de générer le PDF')),
      );
    }
  }

  Future<List<int>> _buildLotReportPdf(
    List<DailyEntry> entries,
    List<LotHistoryEvent> events,
  ) async {
    final doc = pw.Document();
    final timeline = <_PdfTimelineRow>[
      _PdfTimelineRow(
        date: lot.entryDate.toDate(),
        title: 'Entrée du lot',
        details: '${lot.initialBirdCount} sujets - ${lot.buildingName}',
      ),
      ...entries.map(
        (entry) => _PdfTimelineRow(
          date: entry.date.toDate(),
          title: 'Saisie quotidienne',
          details: _isLayer
              ? 'Morts: ${entry.deathsToday} | Oeufs: ${entry.eggsToday ?? 0} | Aliment: ${entry.feedKg} kg'
              : 'Morts: ${entry.deathsToday} | Poids: ${entry.avgWeightKg ?? '-'} kg | Aliment: ${entry.feedKg} kg',
        ),
      ),
      ...events.map(
        (event) => _PdfTimelineRow(
          date: event.eventAt.toDate(),
          title: event.title,
          details: event.description,
        ),
      ),
      if (lot.closedAt != null)
        _PdfTimelineRow(
          date: lot.closedAt!.toDate(),
          title: 'Clôture du lot',
          details: lot.closureReason ?? 'Lot clôturé',
        ),
    ];

    // Order timeline for PDF: force 'Entrée du lot' first, 'Clôture du lot' last,
    // others in-between by date.
    timeline.sort((a, b) {
      int pa() {
        if (a.title == 'Entrée du lot') return -1;
        if (a.title == 'Clôture du lot') return 1;
        return 0;
      }

      int pb() {
        if (b.title == 'Entrée du lot') return -1;
        if (b.title == 'Clôture du lot') return 1;
        return 0;
      }

      final ra = pa();
      final rb = pb();
      if (ra != rb) return ra - rb;
      return a.date.compareTo(b.date);
    });

    // Dedupe timeline entries for PDF (same rules as on-screen):
    // - For entry/closure events, consider same day duplicates
    // - For others, consider same-second duplicates
    final filteredTimeline = <_PdfTimelineRow>[];
    final seenPdf = <String>{};
    for (final row in timeline) {
      final dt = row.date;
      String key;
      if (row.title == 'Entrée du lot' || row.title == 'Clôture du lot') {
        final y = dt.year.toString().padLeft(4, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final d = dt.day.toString().padLeft(2, '0');
        key = '${row.title}|$y-$m-$d';
      } else {
        final seconds = dt.toUtc().millisecondsSinceEpoch ~/ 1000;
        key = '${row.title}|$seconds';
      }

      if (!seenPdf.contains(key)) {
        seenPdf.add(key);
        filteredTimeline.add(row);
      }
    }

    // Compute mortality based on daily entries (more reliable than currentBirdCount)
    final mortalityCount = entries.fold<int>(0, (s, e) => s + e.deathsToday);
    final subjectsOut = lot.closedSubjectsOut ?? 0;
    var currentBirds = lot.initialBirdCount - mortalityCount - subjectsOut;
    if (currentBirds < 0) currentBirds = 0;
    final mortalityRate = lot.initialBirdCount <= 0
        ? 0.0
        : (mortalityCount / lot.initialBirdCount) * 100;

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Bilan du lot ${lot.identifier}',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Bâtiment: ${lot.buildingName}'),
          pw.Text('Type: ${lot.poultryTypeName}'),
          pw.Text('Statut: ${lot.isActive ? 'Actif' : 'Clos'}'),
          pw.Text('Date d\'entrée: ${_formatDate(lot.entryDate.toDate())}'),
          if (lot.closedAt != null)
            pw.Text('Date de clôture: ${_formatDate(lot.closedAt!.toDate())}'),
          pw.SizedBox(height: 12),
          pw.Text(
            'Synthèse',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Bullet(text: 'Sujets initiaux: ${lot.initialBirdCount}'),
          pw.Bullet(text: 'Sujets actuels: $currentBirds'),
          pw.Bullet(
            text:
                'Mortalité: $mortalityCount (${mortalityRate.toStringAsFixed(1)}%)',
          ),
          if (lot.closedSubjectsOut != null)
            if (lot.closedSubjectsOut != null)
              pw.Bullet(text: 'Sujets sortis: ${lot.closedSubjectsOut}'),
          if (lot.finalAvgWeightKg != null)
            pw.Bullet(
              text:
                  'Poids moyen final: ${lot.finalAvgWeightKg!.toStringAsFixed(2)} kg',
            ),
          if (lot.totalEggProduction != null)
            pw.Bullet(
              text: 'Production totale d\'oeufs: ${lot.totalEggProduction}',
            ),
          // Removed 'Résumé' section per UI request (now only on-screen)
          pw.SizedBox(height: 12),
          pw.Text(
            'Journal chronologique',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...filteredTimeline.map(
            (row) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 6),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${_formatDate(row.date)} - ${row.title}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(row.details.isEmpty ? '-' : row.details),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  Future<Directory> _resolvePdfDirectory() async {
    final downloadsDirectory = await getDownloadsDirectory();
    if (downloadsDirectory != null) {
      final appDirectory = Directory(
        '${downloadsDirectory.path}${Platform.pathSeparator}Kiwo',
      );
      if (!await appDirectory.exists()) {
        await appDirectory.create(recursive: true);
      }
      return appDirectory;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final appDirectory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}Kiwo',
    );
    if (!await appDirectory.exists()) {
      await appDirectory.create(recursive: true);
    }
    return appDirectory;
  }

  String _sanitizeFileName(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique — ${lot.identifier}'),
        actions: [
          IconButton(
            tooltip: 'Télécharger le bilan PDF',
            onPressed: () => _downloadLotReportPdf(context),
            icon: const Icon(Icons.picture_as_pdf_rounded),
          ),
        ],
      ),
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

              // Build raw timeline and sort by timestamp
              final timelineList = <_TimelineRow>[
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
              ];

              timelineList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

              // Remove duplicates. For entry/closure events we dedupe by date
              // (same day = same event), for others we dedupe by second-level
              // timestamp to tolerate tiny differences between sources.
              final filtered = <_TimelineRow>[];
              final seen = <String>{};
              for (final row in timelineList) {
                final dt = row.timestamp.toDate();
                String key;
                if (row.title == 'Entrée du lot' ||
                    row.title == 'Clôture du lot') {
                  final y = dt.year.toString().padLeft(4, '0');
                  final m = dt.month.toString().padLeft(2, '0');
                  final d = dt.day.toString().padLeft(2, '0');
                  key = '${row.title}|$y-$m-$d';
                } else {
                  final seconds = dt.toUtc().millisecondsSinceEpoch ~/ 1000;
                  key = '${row.title}|$seconds';
                }

                if (!seen.contains(key)) {
                  seen.add(key);
                  filtered.add(row);
                }
              }

              if (filtered.isEmpty) {
                return const Center(
                  child: Text('Aucun historique disponible.'),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (lot.closedAt != null)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bilan de clôture',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            if (lot.totalEggProduction != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.egg_outlined, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Production totale d\'œufs: ${lot.totalEggProduction}',
                                  ),
                                ],
                              ),
                            ],
                            if (lot.closureSummary != null) ...[
                              const SizedBox(height: 12),
                              Builder(
                                builder: (ctx) {
                                  final summary = lot.closureSummary;
                                  if (summary is Map) {
                                    final map =
                                        summary as Map<dynamic, dynamic>;
                                    return Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: map.entries
                                          .map((e) {
                                            final rawKey = e.key.toString();
                                            if (_shouldHideSummaryKey(rawKey)) {
                                              return null;
                                            }
                                            final key = _translateSummaryKey(
                                              rawKey,
                                            );
                                            final value = _formatSummaryValue(
                                              e.value,
                                            );
                                            return Chip(
                                              label: Text('$key: $value'),
                                            );
                                          })
                                          .whereType<Widget>()
                                          .toList(),
                                    );
                                  }

                                  // Fallback for string or other types
                                  return Text(_formatSummaryValue(summary));
                                },
                              ),
                            ],
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
                  ...filtered.map(
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

  String _translateSummaryKey(String key) {
    const translations = {
      'totalEggProduction': 'Production totale d\'œufs',
      'lotIdentifier': 'Identifiant du lot',
      'closedBirdCount': 'Sujets sortis',
      'closureDate': 'Date de clôture',
      'finalAvgWeightKg': 'Poids moyen final',
      'lotId': 'Identifiant du lot',
      'closureReason': 'Motif',
      'entryDate': 'Date d\'entrée',
      'startDate': 'Date de début',
      'endDate': 'Date de fin',
      'mortalityRate': 'Taux de mortalité',
      'mortalityCount': 'Nombre de morts',
      'feedConsumption': 'Consommation aliment',
      'initialBirdCount': 'Sujets initiaux',
      'currentBirdCount': 'Sujets actuels',
    };

    final translated = translations[key];
    if (translated != null) {
      return translated;
    }

    final normalized = key
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match[1]} ${match[2]}',
        )
        .trim();

    if (normalized.isEmpty) {
      return key;
    }

    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  bool _shouldHideSummaryKey(String key) {
    const hiddenKeys = {'lotId', 'subjectsOut'};
    return hiddenKeys.contains(key);
  }

  String _formatSummaryValue(dynamic value) {
    if (value == null) {
      return '-';
    }

    if (value is Timestamp) {
      return _formatDate(value.toDate());
    }

    if (value is DateTime) {
      return _formatDate(value);
    }

    if (value is Map) {
      return value.entries
          .map((entry) {
            final entryKey = _translateSummaryKey(entry.key.toString());
            final entryValue = _formatSummaryValue(entry.value);
            return '$entryKey: $entryValue';
          })
          .join(' · ');
    }

    if (value is Iterable) {
      return value.map((item) => _formatSummaryValue(item)).join(', ');
    }

    return value.toString();
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

class _PdfTimelineRow {
  final DateTime date;
  final String title;
  final String details;

  _PdfTimelineRow({
    required this.date,
    required this.title,
    required this.details,
  });
}
