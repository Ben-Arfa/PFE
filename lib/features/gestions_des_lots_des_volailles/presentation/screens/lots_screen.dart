import 'package:flutter/material.dart';
import '../../../gestion_des_types_des_volailles/data/repositories/poultry_type_repository_impl.dart';
import '../../../gestion_des_types_des_volailles/data/services/poultry_type_service.dart';
import '../../../gestions_des_batiments/data/repositories/building_repository_impl.dart';
import '../../../gestions_des_batiments/data/services/building_service.dart';
import '../../data/repositories/lot_repository_impl.dart';
import '../../data/services/lot_service.dart';
import '../../domain/entities/flock_lot.dart';
import 'lot_form_screen.dart';
import '../../../suivi_des_lots/presentation/screens/lot_closure_screen.dart';

class LotsScreen extends StatefulWidget {
  const LotsScreen({super.key});

  @override
  State<LotsScreen> createState() => _LotsScreenState();
}

class _LotsScreenState extends State<LotsScreen> {
  final _lotRepo = LotRepositoryImpl(LotService());
  final _buildingRepo = BuildingRepositoryImpl(BuildingService());
  final _typeRepo = PoultryTypeRepositoryImpl(PoultryTypeService());

  void _openCreate() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LotFormScreen(
          lotRepo: _lotRepo,
          buildingRepo: _buildingRepo,
          typeRepo: _typeRepo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lots de volailles')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<FlockLot>>(
        stream: _lotRepo.watchLots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Impossible de charger les lots: ${snapshot.error}'),
            );
          }

          final lots = snapshot.data ?? const <FlockLot>[];
          if (lots.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Aucun lot créé pour le moment.'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lots.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lot = lots[index];
              return Card(
                child: ListTile(
                  title: Text(lot.identifier),
                  subtitle: Text(
                    '${lot.poultryTypeName} · ${lot.buildingName}',
                  ),
                  isThreeLine: false,
                  trailing: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.end,
                    children: [
                      if (lot.isActive)
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LotClosureScreen(lot: lot),
                            ),
                          ),
                          child: const Text('Clôturer'),
                        )
                      else ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text('Clos'),
                        ),
                        IconButton(
                          tooltip: 'Supprimer le lot',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirmer la suppression'),
                                content: Text(
                                  'Voulez-vous vraiment supprimer le lot "${lot.identifier}" ? Cette action est irréversible.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await _lotRepo.deleteLot(lot.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Lot supprimé'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erreur: $e')),
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
