import 'package:flutter/material.dart';

import 'package:kiwo/core/app_colors.dart';
import 'package:kiwo/core/models.dart';

import '../models/tracking_models.dart';
import '../services/tracking_service.dart';

class TrackingScreen extends StatefulWidget {
  final SystemConfig cfg;

  const TrackingScreen({required this.cfg, super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _service = TrackingService.instance;

  TrackingKind? get _kind =>
      TrackingKindResolver.resolve(widget.cfg.poultryType);

  @override
  Widget build(BuildContext context) {
    if (!widget.cfg.isConfigured) {
      return _EmptyState(
        title: 'Configuration requise',
        message: 'Configure ton elevage avant d\'utiliser le suivi.',
      );
    }

    final kind = _kind;
    if (kind == null) {
      return _EmptyState(
        title: 'Type non pris en charge',
        message:
            'Le suivi est disponible pour: poules pondeuses et poules de chair. Type actuel: ${widget.cfg.poultryType}',
      );
    }

    return StreamBuilder<List<TrackingEntry>>(
      stream: _service.watchByKind(kind),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <TrackingEntry>[];
        final summary = _service.computeSummary(kind, entries);

        return Column(
          children: [
            _Header(
              title: TrackingKindResolver.label(kind),
              icon: TrackingKindResolver.icon(kind),
              onAdd: () => _openAddBottomSheet(context, kind),
            ),
            _SummaryCard(summary: summary),
            const SizedBox(height: 8),
            Expanded(
              child: entries.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun enregistrement pour le moment.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final item = entries[index];
                        return _EntryTile(
                          entry: item,
                          onDelete: () => _service.deleteEntry(item.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _openAddBottomSheet(BuildContext context, TrackingKind kind) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddEntrySheet(
          kind: kind,
          birdCount: widget.cfg.birdCount,
          onSave: (entry) async {
            await _service.saveEntry(entry);
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onAdd;

  const _Header({required this.title, required this.icon, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.green.withValues(alpha: 0.12)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'SUIVI - $title',
              style: const TextStyle(
                color: AppColors.dark,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.green),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final TrackingSummary summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dark.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.title,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.value,
            style: const TextStyle(
              color: AppColors.dark,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary.secondary,
            style: const TextStyle(color: AppColors.muted),
          ),
          if (summary.tertiary.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              summary.tertiary,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final TrackingEntry entry;
  final VoidCallback onDelete;

  const _EntryTile({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}/${entry.date.year}';

    final valueLabel = entry.kind == TrackingKind.layer
        ? 'Oeufs: ${entry.eggs ?? 0} | Casses: ${entry.brokenEggs ?? 0}'
        : 'Poids: ${(entry.avgWeightKg ?? 0).toStringAsFixed(2)} kg | Aliment: ${(entry.feedKg ?? 0).toStringAsFixed(1)} kg';

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          dateLabel,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(valueLabel),
            Text(
              'Mortalite: ${entry.mortality} | Restant: ${entry.remainingBirds}',
            ),
            if (entry.notes.trim().isNotEmpty) Text('Note: ${entry.notes}'),
          ],
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.beetRed,
          ),
        ),
      ),
    );
  }
}

class _AddEntrySheet extends StatefulWidget {
  final TrackingKind kind;
  final int birdCount;
  final Future<void> Function(TrackingEntry entry) onSave;

  const _AddEntrySheet({
    required this.kind,
    required this.birdCount,
    required this.onSave,
  });

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  final _formKey = GlobalKey<FormState>();

  final _weightCtrl = TextEditingController();
  final _feedCtrl = TextEditingController();
  final _eggsCtrl = TextEditingController();
  final _brokenCtrl = TextEditingController(text: '0');
  final _eggWeightCtrl = TextEditingController();
  final _mortalityCtrl = TextEditingController(text: '0');
  final _remainingCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _remainingCtrl.text = widget.birdCount.toString();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _feedCtrl.dispose();
    _eggsCtrl.dispose();
    _brokenCtrl.dispose();
    _eggWeightCtrl.dispose();
    _mortalityCtrl.dispose();
    _remainingCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nouvel enregistrement - ${TrackingKindResolver.label(widget.kind)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _datePicker(context),
              const SizedBox(height: 12),
              if (widget.kind == TrackingKind.layer) ...[
                _field(_eggsCtrl, 'Oeufs recoltes', isInt: true),
                const SizedBox(height: 10),
                _field(_brokenCtrl, 'Oeufs casses', isInt: true),
                const SizedBox(height: 10),
                _field(_eggWeightCtrl, 'Poids moyen oeuf (g)'),
              ] else ...[
                _field(_weightCtrl, 'Poids moyen (kg)'),
                const SizedBox(height: 10),
                _field(_feedCtrl, 'Aliment consomme (kg)'),
              ],
              const SizedBox(height: 10),
              _field(_mortalityCtrl, 'Mortalite', isInt: true),
              const SizedBox(height: 10),
              _field(_remainingCtrl, 'Effectif restant', isInt: true),
              const SizedBox(height: 10),
              _field(
                _notesCtrl,
                'Notes',
                required: false,
                isNumeric: false,
                keyboardType: TextInputType.multiline,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: AppColors.cream,
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.cream,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (selected != null && mounted) {
          setState(() => _date = selected);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.dark.withValues(alpha: 0.1)),
        ),
        child: Text(
          'Date: ${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = true,
    bool isInt = false,
    bool isNumeric = true,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType:
          keyboardType ??
          (isNumeric
              ? (isInt
                    ? TextInputType.number
                    : const TextInputType.numberWithOptions(decimal: true))
              : TextInputType.text),
      validator: (value) {
        final text = (value ?? '').trim();
        if (required && text.isEmpty) return 'Champ requis';
        if (!isNumeric || text.isEmpty) return null;
        if (isInt) {
          return int.tryParse(text) == null ? 'Nombre entier invalide' : null;
        }
        return double.tryParse(text.replaceAll(',', '.')) == null
            ? 'Nombre invalide'
            : null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final entry = TrackingEntry(
      id: '',
      kind: widget.kind,
      date: _date,
      notes: _notesCtrl.text.trim(),
      avgWeightKg: widget.kind == TrackingKind.broiler
          ? _toDouble(_weightCtrl.text)
          : null,
      feedKg: widget.kind == TrackingKind.broiler
          ? _toDouble(_feedCtrl.text)
          : null,
      eggs: widget.kind == TrackingKind.layer ? _toInt(_eggsCtrl.text) : null,
      brokenEggs: widget.kind == TrackingKind.layer
          ? _toInt(_brokenCtrl.text)
          : null,
      avgEggWeightG: widget.kind == TrackingKind.layer
          ? _toDouble(_eggWeightCtrl.text)
          : null,
      mortality: _toInt(_mortalityCtrl.text),
      remainingBirds: _toInt(_remainingCtrl.text),
    );

    await widget.onSave(entry);
    if (mounted) {
      Navigator.of(context).pop();
      setState(() => _saving = false);
    }
  }

  int _toInt(String raw) => int.tryParse(raw.trim()) ?? 0;

  double _toDouble(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.insights_rounded,
              size: 48,
              color: AppColors.green,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
