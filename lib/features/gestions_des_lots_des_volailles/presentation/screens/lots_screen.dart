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

  Future<void> _openCreateLotForm() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LotFormScreen(
          lotRepo: _lotRepo,
          buildingRepo: _buildingRepo,
          typeRepo: _typeRepo,
        ),
      ),
    );

    if (!mounted || created != true) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateLotForm,
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
                            Icons.groups_2_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Lots de volailles',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Gestion des élevages actifs',
                                style: TextStyle(color: Colors.white70),
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
              child: StreamBuilder<List<FlockLot>>(
                stream: _lotRepo.watchLots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Impossible de charger les lots: ${snapshot.error}',
                      ),
                    );
                  }

                  final lots = snapshot.data ?? const <FlockLot>[];
                  if (lots.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: const Text('Aucun lot créé pour le moment.'),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: lots.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lot = lots[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.view_module_rounded,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lot.identifier,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      lot.buildingName,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                alignment: WrapAlignment.end,
                                children: [
                                  if (lot.isActive)
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  LotClosureScreen(lot: lot),
                                            ),
                                          ),
                                      child: const Text('Clôturer'),
                                    )
                                  else ...[
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Text('Clos'),
                                    ),
                                    IconButton(
                                      tooltip: 'Supprimer le lot',
                                      onPressed: () async {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                              'Confirmer la suppression',
                                            ),
                                            content: Text(
                                              'Voulez-vous vraiment supprimer le lot "${lot.identifier}" ? Cette action est irréversible.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  ctx,
                                                ).pop(false),
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
                                              messenger.showSnackBar(
                                                const SnackBar(
                                                  content: Text('Lot supprimé'),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              messenger.showSnackBar(
                                                SnackBar(
                                                  content: Text('Erreur: $e'),
                                                ),
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
                            ],
                          ),
                        ),
                      );
                    },
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
