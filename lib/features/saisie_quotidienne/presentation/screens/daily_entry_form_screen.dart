import 'package:flutter/material.dart';
import '../../../saisie_quotidienne/data/repositories/daily_entry_repository_impl.dart';
import '../../../saisie_quotidienne/data/services/daily_entry_service.dart';
import '../../../saisie_quotidienne/domain/inputs/create_daily_entry_input.dart';
import '../../../gestions_des_lots_des_volailles/domain/entities/flock_lot.dart';

class DailyEntryFormScreen extends StatefulWidget {
  final FlockLot lot;

  const DailyEntryFormScreen({super.key, required this.lot});

  @override
  State<DailyEntryFormScreen> createState() => _DailyEntryFormScreenState();
}

class _DailyEntryFormScreenState extends State<DailyEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deathsCtrl = TextEditingController(text: '0');
  final _eggsCtrl = TextEditingController(text: '0');
  final _weightCtrl = TextEditingController();
  final _feedCtrl = TextEditingController(text: '0');
  final _waterCtrl = TextEditingController(text: '0');
  final _obsCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  final _repo = DailyEntryRepositoryImpl(DailyEntryService());

  bool get _isLayer {
    final name = widget.lot.poultryTypeName.toLowerCase();
    return name.contains('ponde') || name.contains('pondeuse');
  }

  @override
  void dispose() {
    _deathsCtrl.dispose();
    _eggsCtrl.dispose();
    _weightCtrl.dispose();
    _feedCtrl.dispose();
    _waterCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: widget.lot.entryDate.toDate(),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final deaths = int.tryParse(_deathsCtrl.text) ?? 0;
    final eggs = int.tryParse(_eggsCtrl.text);
    final weight = double.tryParse(_weightCtrl.text);
    final feed = double.tryParse(_feedCtrl.text) ?? 0.0;
    final water = double.tryParse(_waterCtrl.text) ?? 0.0;

    final input = CreateDailyEntryInput(
      lotId: widget.lot.id,
      date: _date,
      deathsToday: deaths,
      eggsToday: _isLayer ? (eggs ?? 0) : null,
      avgWeightKg: !_isLayer ? weight : null,
      feedKg: feed,
      waterL: water,
      observations: _obsCtrl.text.isEmpty ? null : _obsCtrl.text,
    );

    try {
      await _repo.createEntry(input);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saisie enregistrée')));
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
      appBar: AppBar(title: const Text('Nouvelle saisie')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  'Date: ${_date.toIso8601String().split('T').first}',
                ),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Changer'),
                ),
              ),
              TextFormField(
                controller: _deathsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nombre de morts aujourd\'hui',
                ),
                validator: (v) => (int.tryParse(v ?? '') == null)
                    ? 'Entrez un nombre valide'
                    : null,
              ),
              if (_isLayer)
                TextFormField(
                  controller: _eggsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nombre d\'œufs produits',
                  ),
                  validator: (v) => (int.tryParse(v ?? '') == null)
                      ? 'Entrez un nombre valide'
                      : null,
                )
              else
                TextFormField(
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Poids moyen (kg)',
                  ),
                  validator: (v) =>
                      (v != null && v.isNotEmpty && double.tryParse(v) == null)
                      ? 'Entrez un poids valide'
                      : null,
                ),
              TextFormField(
                controller: _feedCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quantité d\'aliments (kg)',
                ),
                validator: (v) =>
                    (v != null && v.isNotEmpty && double.tryParse(v) == null)
                    ? 'Entrez un nombre valide'
                    : null,
              ),
              TextFormField(
                controller: _waterCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quantité d\'eau (L)',
                ),
                validator: (v) =>
                    (v != null && v.isNotEmpty && double.tryParse(v) == null)
                    ? 'Entrez un nombre valide'
                    : null,
              ),
              TextFormField(
                controller: _obsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Observations (facultatif)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submit,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
