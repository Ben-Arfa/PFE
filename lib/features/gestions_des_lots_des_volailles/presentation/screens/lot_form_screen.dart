import 'package:flutter/material.dart';
import '../../../gestions_des_batiments/data/repositories/building_repository_impl.dart';
import '../../../gestions_des_batiments/domain/entities/building.dart';
import '../../../gestion_des_types_des_volailles/data/repositories/poultry_type_repository_impl.dart';
import '../../../gestion_des_types_des_volailles/domain/entities/poultry_type.dart';
import '../../data/repositories/lot_repository_impl.dart';
import '../../domain/entities/create_lot_input.dart';

class LotFormScreen extends StatefulWidget {
  final LotRepositoryImpl lotRepo;
  final BuildingRepositoryImpl buildingRepo;
  final PoultryTypeRepositoryImpl typeRepo;

  const LotFormScreen({
    super.key,
    required this.lotRepo,
    required this.buildingRepo,
    required this.typeRepo,
  });

  @override
  State<LotFormScreen> createState() => _LotFormScreenState();
}

class _LotFormScreenState extends State<LotFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _countCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  DateTime _entryDate = DateTime.now();

  Future<void> _save(
    BuildContext context,
    Building building,
    PoultryType type,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await widget.lotRepo.createLot(
        CreateLotInput(
          identifier: _identifierCtrl.text.trim(),
          buildingId: building.id,
          buildingName: building.name,
          poultryTypeId: type.id,
          poultryTypeName: type.name,
          entryDate: _entryDate,
          initialBirdCount: int.parse(_countCtrl.text),
          provenance: _supplierCtrl.text.trim(),
        ),
      );
      messenger.showSnackBar(const SnackBar(content: Text('Lot créé')));
      if (mounted) navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un lot'), elevation: 0),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          widget.buildingRepo.watchAvailableBuildings().first,
          widget.typeRepo.watchAll().first,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final buildings =
              snapshot.data?[0] as List<Building>? ?? const <Building>[];
          final types =
              snapshot.data?[1] as List<PoultryType>? ?? const <PoultryType>[];

          if (buildings.isEmpty || types.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Il faut au moins un type de volaille et un bâtiment vide pour créer un lot.',
                ),
              ),
            );
          }

          var selectedBuilding = buildings.first;
          var selectedType = types.first;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _identifierCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Identifiant du lot',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Identifiant requis'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Building>(
                      initialValue: selectedBuilding,
                      decoration: const InputDecoration(
                        labelText: 'Bâtiment disponible',
                      ),
                      items: buildings
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) selectedBuilding = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<PoultryType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type de volaille',
                      ),
                      items: types
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) selectedType = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _countCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre initial de sujets',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => int.tryParse(value ?? '') == null
                          ? 'Nombre entier requis'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _supplierCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Provenance (couvoir / fournisseur)',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Provenance requise'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date d’entrée'),
                      subtitle: Text(
                        '${_entryDate.day.toString().padLeft(2, '0')}/${_entryDate.month.toString().padLeft(2, '0')}/${_entryDate.year}',
                      ),
                      trailing: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _entryDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _entryDate = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: const Text('Choisir'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () =>
                          _save(context, selectedBuilding, selectedType),
                      icon: const Icon(Icons.save),
                      label: const Text('Créer le lot'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
