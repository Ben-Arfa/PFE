import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/form_section.dart';
import '../../data/repositories/poultry_type_repository_impl.dart';
import '../../domain/entities/poultry_type.dart';
import '../../domain/entities/poultry_type_input.dart';

class CreateTypeScreen extends StatefulWidget {
  final PoultryTypeRepositoryImpl repo;
  final PoultryType? existingType;

  const CreateTypeScreen({super.key, required this.repo, this.existingType});

  @override
  State<CreateTypeScreen> createState() => _CreateTypeScreenState();
}

class _CreateTypeScreenState extends State<CreateTypeScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _category;
  late double _tempMin;
  late double _tempMax;
  late double _humMin;
  late double _humMax;
  late double _density;
  late double _lightHours;
  late int _duration;
  double? _targetWeight;
  int? _layStartAge;

  bool get _isEdit => widget.existingType != null;

  @override
  void initState() {
    super.initState();
    final type = widget.existingType;
    _name = type?.name ?? '';
    _category = type?.category ?? 'chair';
    _tempMin = type?.targetTempMin ?? 20;
    _tempMax = type?.targetTempMax ?? 30;
    _humMin = type?.targetHumidityMin ?? 40;
    _humMax = type?.targetHumidityMax ?? 60;
    _density = type?.recommendedDensity ?? 5;
    _lightHours = type?.recommendedLightHours ?? 14;
    _duration = type?.typicalDurationDays ?? 90;
    _targetWeight = type?.targetWeightKg;
    _layStartAge = type?.layStartAgeDays;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final input = PoultryTypeInput(
      name: _name,
      category: _category,
      targetTempMin: _tempMin,
      targetTempMax: _tempMax,
      targetHumidityMin: _humMin,
      targetHumidityMax: _humMax,
      recommendedDensity: _density,
      recommendedLightHours: _lightHours,
      typicalDurationDays: _duration,
      targetWeightKg: _category == 'chair' ? _targetWeight : null,
      layStartAgeDays: _category == 'pondeuse' ? _layStartAge : null,
    );

    try {
      if (_isEdit) {
        await widget.repo.update(widget.existingType!.id, input);
        messenger.showSnackBar(const SnackBar(content: Text('Type modifié')));
      } else {
        await widget.repo.create(input);
        messenger.showSnackBar(const SnackBar(content: Text('Type créé')));
      }
      if (mounted) navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier le type' : 'Créer un type de volaille'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informations générales
                FormSection(
                  title: 'Informations générales',
                  children: [
                    DecoratedFormField(
                      label: 'Nom du type',
                      hint: 'ex: Poulet de chair standard',
                      initialValue: _name,
                      onSaved: (v) => _name = v?.trim() ?? '',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                    ),
                    const SizedBox(height: 12),
                    DecoratedDropdown<String>(
                      label: 'Catégorie',
                      value: _category,
                      items: const [
                        DropdownMenuItem(value: 'chair', child: Text('Chair')),
                        DropdownMenuItem(
                          value: 'pondeuse',
                          child: Text('Pondeuse'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _category = v ?? 'chair'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Paramètres climatiques
                FormSection(
                  title: 'Paramètres climatiques',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DecoratedFormField(
                            label: 'Temp min',
                            hint: '20',
                            initialValue: _tempMin.toString(),
                            keyboardType: TextInputType.number,
                            validator: (v) => double.tryParse(v ?? '') == null
                                ? 'Nombre'
                                : null,
                            onSaved: (v) => _tempMin = double.parse(v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DecoratedFormField(
                            label: 'Temp max',
                            hint: '30',
                            initialValue: _tempMax.toString(),
                            keyboardType: TextInputType.number,
                            validator: (v) => double.tryParse(v ?? '') == null
                                ? 'Nombre'
                                : null,
                            onSaved: (v) => _tempMax = double.parse(v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DecoratedFormField(
                            label: 'Hum min',
                            hint: '40',
                            initialValue: _humMin.toString(),
                            keyboardType: TextInputType.number,
                            validator: (v) => double.tryParse(v ?? '') == null
                                ? 'Nombre'
                                : null,
                            onSaved: (v) => _humMin = double.parse(v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DecoratedFormField(
                            label: 'Hum max',
                            hint: '60',
                            initialValue: _humMax.toString(),
                            keyboardType: TextInputType.number,
                            validator: (v) => double.tryParse(v ?? '') == null
                                ? 'Nombre'
                                : null,
                            onSaved: (v) => _humMax = double.parse(v!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Paramètres d'élevage
                FormSection(
                  title: 'Paramètres d\'élevage',

                  children: [
                    DecoratedFormField(
                      label: 'Densité (volailles/m²)',
                      hint: '5',
                      initialValue: _density.toString(),
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v ?? '') == null
                          ? 'Nombre requis'
                          : null,
                      onSaved: (v) => _density = double.parse(v!),
                    ),
                    const SizedBox(height: 12),
                    DecoratedFormField(
                      label: 'Programme lumineux (heures/jour)',
                      hint: '14',
                      initialValue: _lightHours.toString(),
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v ?? '') == null
                          ? 'Nombre requis'
                          : null,
                      onSaved: (v) => _lightHours = double.parse(v!),
                    ),
                    const SizedBox(height: 12),
                    DecoratedFormField(
                      label: 'Durée typique (jours)',
                      hint: '90',
                      initialValue: _duration.toString(),
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v ?? '') == null
                          ? 'Nombre entier requis'
                          : null,
                      onSaved: (v) => _duration = int.parse(v!),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Paramètres spécifiques
                if (_category == 'chair')
                  Column(
                    children: [
                      FormSection(
                        title: 'Production (Chairs)',
                        children: [
                          DecoratedFormField(
                            label: 'Poids cible à l\'abattage (kg)',
                            hint: '2.5',
                            initialValue: _targetWeight?.toString() ?? '',
                            keyboardType: TextInputType.number,
                            validator: (v) => double.tryParse(v ?? '') == null
                                ? 'Nombre requis'
                                : null,
                            onSaved: (v) => _targetWeight = double.parse(v!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                if (_category == 'pondeuse')
                  Column(
                    children: [
                      FormSection(
                        title: 'Production (Pondeuses)',
                        children: [
                          DecoratedFormField(
                            label: 'Âge de début de ponte (jours)',
                            hint: '120',

                            initialValue: _layStartAge?.toString() ?? '',
                            keyboardType: TextInputType.number,
                            validator: (v) => int.tryParse(v ?? '') == null
                                ? 'Nombre entier requis'
                                : null,
                            onSaved: (v) => _layStartAge = int.parse(v!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Bouton d'action
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _isEdit ? 'Enregistrer les modifications' : 'Créer le type',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
