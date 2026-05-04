import 'package:flutter/material.dart';
import '../../data/repositories/building_repository_impl.dart';
import '../../data/services/building_service.dart';
import '../../domain/entities/building.dart';
import 'building_form_screen.dart';

class BuildingsScreen extends StatefulWidget {
  const BuildingsScreen({super.key});

  @override
  State<BuildingsScreen> createState() => _BuildingsScreenState();
}

class _BuildingsScreenState extends State<BuildingsScreen> {
  final _service = BuildingService();
  late final _repo = BuildingRepositoryImpl(_service);
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreate() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => BuildingFormScreen(repo: _repo)));
  }

  void _openEdit(Building building) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BuildingFormScreen(repo: _repo, initialBuilding: building),
      ),
    );
  }

  Future<void> _delete(Building building) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le bâtiment ?'),
        content: Text('Le bâtiment "${building.name}" sera supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _repo.deleteBuilding(building.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${building.name} supprimé')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 160,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.home_work_rounded,
                      size: 54,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Bâtiments',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Suivi des capacités et statuts',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Rechercher un bâtiment',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _openCreate,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Building>>(
                stream: _repo.watchBuildings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Impossible de charger les bâtiments: ${snapshot.error}',
                      ),
                    );
                  }

                  final buildings = (snapshot.data ?? const <Building>[]).where(
                    (building) {
                      if (_query.isEmpty) return true;
                      return building.name.toLowerCase().contains(_query) ||
                          building.status.label.toLowerCase().contains(
                            _query,
                          ) ||
                          (building.activePoultryTypeName ?? '')
                              .toLowerCase()
                              .contains(_query);
                    },
                  ).toList();

                  if (buildings.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aucun bâtiment trouvé. Appuyez sur Ajouter pour en créer un.',
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: buildings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final building = buildings[index];
                      final statusColor = switch (building.status) {
                        BuildingStatus.active => Colors.green,
                        BuildingStatus.empty => Colors.blue,
                        BuildingStatus.disinfecting => Colors.orange,
                      };

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () => _openEdit(building),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: statusColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  foregroundColor: statusColor,
                                  child: Text(
                                    building.status.label.substring(0, 1),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        building.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${building.areaM2.toStringAsFixed(1)} m² · ${building.capacityMax} sujets · ${building.status.label}',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _openEdit(building);
                                    } else {
                                      _delete(building);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Modifier'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Supprimer'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
