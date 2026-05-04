import 'package:flutter/material.dart';
import '../../data/repositories/poultry_type_repository_impl.dart';
import '../../data/services/poultry_type_service.dart';
import '../../domain/entities/poultry_type.dart';
import 'create_type_screen.dart';

class TypesScreen extends StatefulWidget {
  const TypesScreen({super.key});

  @override
  State<TypesScreen> createState() => _TypesScreenState();
}

class _TypesScreenState extends State<TypesScreen> {
  final _service = PoultryTypeService();
  late final _repo = PoultryTypeRepositoryImpl(_service);
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

  void _openCreateScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CreateTypeScreen(repo: _repo)));
  }

  void _openEditScreen(PoultryType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateTypeScreen(repo: _repo, existingType: type),
      ),
    );
  }

  Future<void> _confirmDelete(PoultryType type) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le type'),
        content: Text(
          'Supprimer ${type.name} ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await _repo.delete(type.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${type.name} supprimé')));
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
            // Hero header
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
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pets,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Types de volailles',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Gérez les races et paramètres',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Actions + search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Rechercher un type',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _openCreateScreen,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: StreamBuilder<List<PoultryType>>(
                stream: _repo.watchAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Impossible de charger les types: ${snapshot.error}',
                      ),
                    );
                  }

                  final types = (snapshot.data ?? []).where((t) {
                    if (_query.isEmpty) return true;
                    return t.name.toLowerCase().contains(_query) ||
                        t.category.toLowerCase().contains(_query);
                  }).toList();

                  if (types.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aucun type trouvé. Appuyez sur Ajouter pour en créer un.',
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: types.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final type = types[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () => _openEditScreen(type),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(child: const Icon(Icons.pets)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        type.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${type.category == 'chair' ? 'Chair' : 'Pondeuse'} · ${type.targetTempMin.toStringAsFixed(1)}-${type.targetTempMax.toStringAsFixed(1)}°C · ${type.targetHumidityMin.toStringAsFixed(1)}-${type.targetHumidityMax.toStringAsFixed(1)}%',
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
                                    if (value == 'edit') _openEditScreen(type);
                                    if (value == 'delete') _confirmDelete(type);
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
