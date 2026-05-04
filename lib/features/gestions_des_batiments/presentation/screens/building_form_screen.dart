import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/form_section.dart';
import '../../data/repositories/building_repository_impl.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/building_input.dart';

class BuildingFormScreen extends StatefulWidget {
  final BuildingRepositoryImpl repo;
  final Building? initialBuilding;

  const BuildingFormScreen({
    super.key,
    required this.repo,
    this.initialBuilding,
  });

  @override
  State<BuildingFormScreen> createState() => _BuildingFormScreenState();
}

class _BuildingFormScreenState extends State<BuildingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late double _areaM2;
  late int _capacityMax;
  late BuildingStatus _status;

  bool get _isEdit => widget.initialBuilding != null;

  @override
  void initState() {
    super.initState();
    final building = widget.initialBuilding;
    _name = building?.name ?? '';
    _areaM2 = building?.areaM2 ?? 0;
    _capacityMax = building?.capacityMax ?? 0;
    _status = building?.status ?? BuildingStatus.empty;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final input = BuildingInput(
      name: _name,
      areaM2: _areaM2,
      capacityMax: _capacityMax,
      status: _status,
    );

    try {
      if (_isEdit) {
        await widget.repo.updateBuilding(widget.initialBuilding!.id, input);
        messenger.showSnackBar(
          const SnackBar(content: Text('Bâtiment mis à jour')),
        );
      } else {
        await widget.repo.createBuilding(input);
        messenger.showSnackBar(const SnackBar(content: Text('Bâtiment créé')));
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
        title: Text(_isEdit ? 'Modifier un bâtiment' : 'Créer un bâtiment'),
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
                      label: 'Nom ou identifiant',
                      hint: 'ex: Poulailler A, Bâtiment 1',
                      initialValue: _name,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Nom requis'
                          : null,
                      onSaved: (value) => _name = value?.trim() ?? '',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dimensions et capacité
                FormSection(
                  title: 'Dimensions et capacité',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DecoratedFormField(
                            label: 'Superficie (m²)',
                            hint: '100',
                            initialValue: _areaM2 == 0
                                ? ''
                                : _areaM2.toString(),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                double.tryParse(value ?? '') == null
                                ? 'Nombre requis'
                                : null,
                            onSaved: (value) => _areaM2 = double.parse(value!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DecoratedFormField(
                            label: 'Capacité max',
                            hint: '1000',
                            initialValue: _capacityMax == 0
                                ? ''
                                : _capacityMax.toString(),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                int.tryParse(value ?? '') == null
                                ? 'Nombre requis'
                                : null,
                            onSaved: (value) =>
                                _capacityMax = int.parse(value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Statut
                FormSection(
                  title: 'Statut',
                  children: [
                    DecoratedDropdown<BuildingStatus>(
                      label: 'État du bâtiment',
                      items: BuildingStatus.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(
                        () => _status = value ?? BuildingStatus.empty,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Bouton d'action
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _isEdit
                        ? 'Enregistrer les modifications'
                        : 'Créer le bâtiment',
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
