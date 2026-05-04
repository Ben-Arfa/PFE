import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiwo/app/di/service_locator.dart';
import 'package:kiwo/features/farm_management/domain/entities/farm_management_inputs.dart';
import 'package:kiwo/features/farm_management/domain/entities/farm_management_models.dart';
import 'package:kiwo/features/farm_management/domain/usecases/farm_management_usecases.dart';
import 'package:kiwo/shared/presentation/theme/app_colors.dart';
import 'package:kiwo/shared/presentation/theme/kiwo_theme.dart';
import 'package:kiwo/shared/presentation/theme/theme_provider.dart';

class FarmManagementScreen extends StatefulWidget {
  final bool showShell;

  const FarmManagementScreen({this.showShell = true, super.key});

  @override
  State<FarmManagementScreen> createState() => _FarmManagementScreenState();
}

class _FarmManagementScreenState extends State<FarmManagementScreen> {
  final FarmManagementUseCases _farmUseCases = FarmManagementUseCases();
  final _authUseCases = ServiceLocator.instance.authUseCases;

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;

    if (!widget.showShell) {
      return DefaultTabController(
        length: 5,
        child: KiwoThemeWrapper(
          child: Container(
            color: t.bgColor,
            child: Column(
              children: [
                Material(
                  color: t.headerColor,
                  child: TabBar(
                    isScrollable: true,
                    indicatorColor: AppColors.green,
                    labelColor: t.textColor,
                    tabs: const [
                      Tab(text: 'Vue'),
                      Tab(text: 'Types'),
                      Tab(text: 'Batiments'),
                      Tab(text: 'Lots'),
                      Tab(text: 'Suivi'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildOverviewTab(),
                      _buildPoultryTypesTab(),
                      _buildBuildingsTab(),
                      _buildLotsTab(),
                      _buildTrackingTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      child: KiwoThemeWrapper(
        child: Scaffold(
          backgroundColor: t.bgColor,
          appBar: AppBar(
            backgroundColor: t.headerColor,
            foregroundColor: t.textColor,
            elevation: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion de l elevage',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  'Kiwo',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Deconnexion',
                onPressed: _authUseCases.signOut,
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: AppColors.green,
              labelColor: t.textColor,
              tabs: const [
                Tab(text: 'Vue'),
                Tab(text: 'Types'),
                Tab(text: 'Batiments'),
                Tab(text: 'Lots'),
                Tab(text: 'Suivi'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildOverviewTab(),
              _buildPoultryTypesTab(),
              _buildBuildingsTab(),
              _buildLotsTab(),
              _buildTrackingTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return StreamBuilder<List<PoultryType>>(
      stream: _farmUseCases.watchPoultryTypes(),
      builder: (context, typesSnapshot) {
        return StreamBuilder<List<Building>>(
          stream: _farmUseCases.watchBuildings(),
          builder: (context, buildingsSnapshot) {
            return StreamBuilder<List<FlockLot>>(
              stream: _farmUseCases.watchLots(),
              builder: (context, lotsSnapshot) {
                if (typesSnapshot.connectionState == ConnectionState.waiting &&
                    buildingsSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    lotsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final types = typesSnapshot.data ?? const <PoultryType>[];
                final buildings = buildingsSnapshot.data ?? const <Building>[];
                final lots = lotsSnapshot.data ?? const <FlockLot>[];
                final activeLots = lots.where((lot) => lot.isActive).toList();
                final emptyBuildings = buildings
                    .where(
                      (building) => building.status == BuildingStatus.empty,
                    )
                    .length;
                final liveBirds = activeLots.fold<int>(
                  0,
                  (total, lot) => total + lot.currentBirdCount,
                );

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StatCard(
                          label: 'Types crees',
                          value: '${types.length}',
                          icon: Icons.category_rounded,
                        ),
                        _StatCard(
                          label: 'Batiments libres',
                          value: '$emptyBuildings',
                          icon: Icons.home_work_rounded,
                        ),
                        _StatCard(
                          label: 'Lots actifs',
                          value: '${activeLots.length}',
                          icon: Icons.layers_rounded,
                        ),
                        _StatCard(
                          label: 'Sujets vivants',
                          value: '$liveBirds',
                          icon: Icons.pets_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Lots en cours',
                      subtitle:
                          'Vue rapide des batiments occupes et des saisies a faire.',
                      child: activeLots.isEmpty
                          ? const _EmptyState(
                              title: 'Aucun lot actif',
                              message:
                                  'Cree d abord un type, un batiment, puis un lot pour lancer le suivi.',
                            )
                          : Column(
                              children: activeLots
                                  .map(
                                    (lot) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _LotOverviewTile(
                                        lot: lot,
                                        onTrack: () => _handleDailyEntry(lot),
                                        onJournal: () => _openJournalSheet(lot),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Raccourcis',
                      subtitle:
                          'Actions les plus courantes pour demarrer la gestion.',
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: _handleCreatePoultryType,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Nouveau type'),
                          ),
                          FilledButton.icon(
                            onPressed: _handleCreateBuilding,
                            icon: const Icon(Icons.add_business_rounded),
                            label: const Text('Nouveau batiment'),
                          ),
                          FilledButton.icon(
                            onPressed: _handleCreateLot,
                            icon: const Icon(Icons.layers_rounded),
                            label: const Text('Nouveau lot'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPoultryTypesTab() {
    return StreamBuilder<List<PoultryType>>(
      stream: _farmUseCases.watchPoultryTypes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? const <PoultryType>[];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(
              title: 'Types de volailles',
              subtitle:
                  'Leur categorie pilote le formulaire quotidien et les indicateurs du lot.',
              actionLabel: 'Ajouter',
              onAction: _handleCreatePoultryType,
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const _EmptyState(
                title: 'Aucun type enregistre',
                message:
                    'Ajoute par exemple un poulet de chair ou une pondeuse pour demarrer.',
              )
            else
              ...items.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PoultryTypeCard(
                    item: type,
                    onEdit: () => _handleEditPoultryType(type),
                    onDelete: () => _handleDeletePoultryType(type),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBuildingsTab() {
    return StreamBuilder<List<Building>>(
      stream: _farmUseCases.watchBuildings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? const <Building>[];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(
              title: 'Batiments',
              subtitle:
                  'Chaque batiment ne peut heberger qu un seul lot actif a la fois.',
              actionLabel: 'Ajouter',
              onAction: _handleCreateBuilding,
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const _EmptyState(
                title: 'Aucun batiment',
                message:
                    'Cree tes batiments pour pouvoir affecter des lots et suivre leur occupation.',
              )
            else
              ...items.map(
                (building) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BuildingCard(
                    item: building,
                    onEdit: () => _handleEditBuilding(building),
                    onDelete: () => _handleDeleteBuilding(building),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLotsTab() {
    return StreamBuilder<List<PoultryType>>(
      stream: _farmUseCases.watchPoultryTypes(),
      builder: (context, typesSnapshot) {
        return StreamBuilder<List<Building>>(
          stream: _farmUseCases.watchAvailableBuildings(),
          builder: (context, availableBuildingsSnapshot) {
            return StreamBuilder<List<FlockLot>>(
              stream: _farmUseCases.watchLots(),
              builder: (context, lotsSnapshot) {
                if (typesSnapshot.connectionState == ConnectionState.waiting &&
                    availableBuildingsSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    lotsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final lots = lotsSnapshot.data ?? const <FlockLot>[];
                final activeLots = lots.where((lot) => lot.isActive).toList();
                final closedLots = lots.where((lot) => !lot.isActive).toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _SectionHeader(
                      title: 'Gestion des lots',
                      subtitle:
                          'Creation, cloture et consultation du journal chronologique.',
                      actionLabel: 'Creer un lot',
                      onAction: _handleCreateLot,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Lots actifs',
                      child: activeLots.isEmpty
                          ? const _EmptyState(
                              title: 'Aucun lot en cours',
                              message:
                                  'Tous les batiments sont disponibles. Cree un lot pour demarrer.',
                            )
                          : Column(
                              children: activeLots
                                  .map(
                                    (lot) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _LotCard(
                                        lot: lot,
                                        onClose: () => _handleCloseLot(lot),
                                        onJournal: () => _openJournalSheet(lot),
                                        onTrack: () => _handleDailyEntry(lot),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Historique des lots clotures',
                      child: closedLots.isEmpty
                          ? const _EmptyState(
                              title: 'Aucun lot cloture',
                              message:
                                  'Le bilan de fin de lot apparaitra ici apres la premiere sortie.',
                            )
                          : Column(
                              children: closedLots
                                  .map(
                                    (lot) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _ClosedLotCard(
                                        lot: lot,
                                        onJournal: () => _openJournalSheet(lot),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTrackingTab() {
    return StreamBuilder<List<FlockLot>>(
      stream: _farmUseCases.watchLots(status: LotStatus.active),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeLots = snapshot.data ?? const <FlockLot>[];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(
              title: 'Suivi quotidien',
              subtitle:
                  'Le formulaire change selon la categorie CHAIR ou PONDEUSE.',
            ),
            const SizedBox(height: 12),
            if (activeLots.isEmpty)
              const _EmptyState(
                title: 'Aucun lot actif a suivre',
                message:
                    'Le suivi quotidien se debloque automatiquement apres la creation d un lot.',
              )
            else
              ...activeLots.map(
                (lot) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TrackingLotCard(
                    lot: lot,
                    entriesStream: _farmUseCases.watchDailyEntries(lot.id),
                    onTrack: () => _handleDailyEntry(lot),
                    onHistory: () => _openDailyHistorySheet(lot),
                    onJournal: () => _openJournalSheet(lot),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _handleCreatePoultryType() async {
    final input = await _showPoultryTypeDialog();
    if (input == null) return;
    await _runAction(
      () => _farmUseCases.createPoultryType(input),
      successMessage: 'Type de volaille cree.',
    );
  }

  Future<void> _handleEditPoultryType(PoultryType type) async {
    final input = await _showPoultryTypeDialog(initial: type);
    if (input == null) return;
    await _runAction(
      () =>
          _farmUseCases.updatePoultryType(poultryTypeId: type.id, input: input),
      successMessage: 'Type de volaille mis a jour.',
    );
  }

  Future<void> _handleDeletePoultryType(PoultryType type) async {
    final confirmed = await _confirm(
      title: 'Supprimer ce type ?',
      message: 'Le type "${type.name}" sera retire de la liste.',
    );
    if (!confirmed) return;
    await _runAction(
      () => _farmUseCases.deletePoultryType(type.id),
      successMessage: 'Type de volaille supprime.',
    );
  }

  Future<void> _handleCreateBuilding() async {
    final input = await _showBuildingDialog();
    if (input == null) return;
    await _runAction(
      () => _farmUseCases.createBuilding(input),
      successMessage: 'Batiment cree.',
    );
  }

  Future<void> _handleEditBuilding(Building building) async {
    final input = await _showBuildingDialog(initial: building);
    if (input == null) return;
    await _runAction(
      () => _farmUseCases.updateBuilding(buildingId: building.id, input: input),
      successMessage: 'Batiment mis a jour.',
    );
  }

  Future<void> _handleDeleteBuilding(Building building) async {
    final confirmed = await _confirm(
      title: 'Supprimer ce batiment ?',
      message: 'Le batiment "${building.name}" sera retire.',
    );
    if (!confirmed) return;
    await _runAction(
      () => _farmUseCases.deleteBuilding(building.id),
      successMessage: 'Batiment supprime.',
    );
  }

  Future<void> _handleCreateLot() async {
    final types = await _farmUseCases.watchPoultryTypes().first;
    final availableBuildings = await _farmUseCases
        .watchAvailableBuildings()
        .first;
    final input = await _showCreateLotDialog(
      poultryTypes: types,
      availableBuildings: availableBuildings,
    );
    if (input == null) return;
    await _runAction(
      () => _farmUseCases.createLot(input),
      successMessage: 'Lot cree et batiment passe en ACTIF.',
    );
  }

  Future<void> _handleCloseLot(FlockLot lot) async {
    final input = await _showCloseLotDialog(lot);
    if (input == null) return;
    await _runAction(
      () => _farmUseCases.closeLot(input),
      successMessage: 'Lot cloture et batiment libere.',
    );
  }

  Future<void> _handleDailyEntry(FlockLot lot) async {
    final input = await _showDailyEntryDialog(lot);
    if (input == null) return;
    await _runAction(
      () => _farmUseCases.createDailyEntry(input),
      successMessage: 'Saisie quotidienne enregistree.',
    );
  }

  Future<void> _openJournalSheet(FlockLot lot) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemeProvider.instance.dialogBg,
      builder: (context) {
        final t = ThemeProvider.instance;
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: SafeArea(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Journal du lot ${lot.identifier}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${lot.poultryTypeName} - ${lot.buildingName}',
                  ),
                  trailing: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final input = await _showJournalNoteDialog(
                            lotId: lot.id,
                            type: JournalEventType.vaccination,
                          );
                          if (!mounted || input == null) return;
                          await _runAction(
                            () => _farmUseCases.addJournalEvent(input),
                            successMessage: 'Vaccination ajoutee au journal.',
                          );
                        },
                        icon: const Icon(Icons.vaccines_rounded),
                        label: const Text('Vaccination'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final input = await _showJournalNoteDialog(
                            lotId: lot.id,
                            type: JournalEventType.alert,
                          );
                          if (!mounted || input == null) return;
                          await _runAction(
                            () => _farmUseCases.addJournalEvent(input),
                            successMessage: 'Alerte ajoutee au journal.',
                          );
                        },
                        icon: const Icon(Icons.warning_amber_rounded),
                        label: const Text('Alerte'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: StreamBuilder<List<LotJournalEvent>>(
                    stream: _farmUseCases.watchLotJournal(lot.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final events = snapshot.data ?? const <LotJournalEvent>[];
                      if (events.isEmpty) {
                        return const _EmptyState(
                          title: 'Journal vide',
                          message:
                              'Les evenements du lot apparaitront ici au fil du cycle.',
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: events.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: t.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: t.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _StatusBadge(
                                      label: event.type.label,
                                      color: _eventColor(event.type),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _formatDate(event.occurredAt),
                                      style: TextStyle(
                                        color: t.mutedColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  event.title,
                                  style: TextStyle(
                                    color: t.textColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (event.description.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    event.description,
                                    style: TextStyle(color: t.mutedColor),
                                  ),
                                ],
                              ],
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
      },
    );
  }

  Future<void> _openDailyHistorySheet(FlockLot lot) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemeProvider.instance.dialogBg,
      builder: (context) {
        final t = ThemeProvider.instance;
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: SafeArea(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Historique des saisies - ${lot.identifier}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(lot.category.label),
                  trailing: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: StreamBuilder<List<DailyEntry>>(
                    stream: _farmUseCases.watchDailyEntries(lot.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final entries = snapshot.data ?? const <DailyEntry>[];
                      if (entries.isEmpty) {
                        return const _EmptyState(
                          title: 'Pas encore de saisie',
                          message:
                              'Ajoute la premiere saisie pour suivre mortalite et performances.',
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: t.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: t.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _formatDate(entry.entryDate),
                                      style: TextStyle(
                                        color: t.textColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Morts ${entry.dailyMortality}',
                                      style: TextStyle(color: t.mutedColor),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _MetricChip(
                                      label: 'Aliment',
                                      value:
                                          '${entry.feedKg.toStringAsFixed(1)} kg',
                                    ),
                                    _MetricChip(
                                      label: 'Eau',
                                      value:
                                          '${entry.waterLiters.toStringAsFixed(1)} L',
                                    ),
                                    _MetricChip(
                                      label: 'Mortalite cumulee',
                                      value:
                                          '${entry.cumulativeMortalityRate.toStringAsFixed(1)} %',
                                    ),
                                    if (lot.category ==
                                        PoultryCategory.meat) ...[
                                      _MetricChip(
                                        label: 'Poids',
                                        value:
                                            '${(entry.averageWeightKg ?? 0).toStringAsFixed(2)} kg',
                                      ),
                                      _MetricChip(
                                        label: 'GMQ',
                                        value:
                                            '${(entry.dailyWeightGainG ?? 0).toStringAsFixed(1)} g/j',
                                      ),
                                      _MetricChip(
                                        label: 'IC',
                                        value: (entry.feedConversionRatio ?? 0)
                                            .toStringAsFixed(2),
                                      ),
                                    ] else ...[
                                      _MetricChip(
                                        label: 'Oeufs',
                                        value: '${entry.eggCount ?? 0}',
                                      ),
                                      _MetricChip(
                                        label: 'Taux de ponte',
                                        value:
                                            '${(entry.layRate ?? 0).toStringAsFixed(1)} %',
                                      ),
                                      _MetricChip(
                                        label: 'Pic',
                                        value:
                                            '${(entry.peakLayRate ?? 0).toStringAsFixed(1)} %',
                                      ),
                                    ],
                                  ],
                                ),
                                if (entry.notes.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    entry.notes,
                                    style: TextStyle(color: t.mutedColor),
                                  ),
                                ],
                              ],
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
      },
    );
  }

  Future<PoultryTypeInput?> _showPoultryTypeDialog({PoultryType? initial}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: initial?.name ?? '');
    final tempMinCtrl = TextEditingController(
      text: _decimalText(initial?.targetTempMin),
    );
    final tempMaxCtrl = TextEditingController(
      text: _decimalText(initial?.targetTempMax),
    );
    final humidityMinCtrl = TextEditingController(
      text: _decimalText(initial?.targetHumidityMin),
    );
    final humidityMaxCtrl = TextEditingController(
      text: _decimalText(initial?.targetHumidityMax),
    );
    final densityCtrl = TextEditingController(
      text: _decimalText(initial?.recommendedDensity),
    );
    final lightCtrl = TextEditingController(
      text: _decimalText(initial?.recommendedLightHours),
    );
    final durationCtrl = TextEditingController(
      text: initial?.typicalDurationDays.toString() ?? '',
    );
    final targetCtrl = TextEditingController(
      text: _decimalText(initial?.targetValue),
    );
    var category = initial?.category ?? PoultryCategory.meat;

    return showDialog<PoultryTypeInput>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                initial == null
                    ? 'Nouveau type de volaille'
                    : 'Modifier le type',
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DialogTextField(
                          controller: nameCtrl,
                          label: 'Nom du type',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<PoultryCategory>(
                          initialValue: category,
                          decoration: const InputDecoration(
                            labelText: 'Categorie',
                            border: OutlineInputBorder(),
                          ),
                          items: PoultryCategory.values
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => category = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _DialogTextField(
                                controller: tempMinCtrl,
                                label: 'Temp min (C)',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: _requiredValidator,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DialogTextField(
                                controller: tempMaxCtrl,
                                label: 'Temp max (C)',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: _requiredValidator,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _DialogTextField(
                                controller: humidityMinCtrl,
                                label: 'Humidite min (%)',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: _requiredValidator,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DialogTextField(
                                controller: humidityMaxCtrl,
                                label: 'Humidite max (%)',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: _requiredValidator,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: densityCtrl,
                          label: 'Densite recommandee (sujets/m2)',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: lightCtrl,
                          label: 'Programme lumineux (h/jour)',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: durationCtrl,
                          label: 'Duree d elevage (jours)',
                          keyboardType: TextInputType.number,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: targetCtrl,
                          label: category.targetMetricLabel,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _requiredValidator,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(dialogContext).pop(
                      PoultryTypeInput(
                        name: nameCtrl.text.trim(),
                        category: category,
                        targetTempMin: _parseDouble(tempMinCtrl.text),
                        targetTempMax: _parseDouble(tempMaxCtrl.text),
                        targetHumidityMin: _parseDouble(humidityMinCtrl.text),
                        targetHumidityMax: _parseDouble(humidityMaxCtrl.text),
                        recommendedDensity: _parseDouble(densityCtrl.text),
                        recommendedLightHours: _parseDouble(lightCtrl.text),
                        typicalDurationDays: _parseInt(durationCtrl.text),
                        targetValue: _parseDouble(targetCtrl.text),
                      ),
                    );
                  },
                  child: Text(initial == null ? 'Creer' : 'Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<BuildingInput?> _showBuildingDialog({Building? initial}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: initial?.name ?? '');
    final areaCtrl = TextEditingController(text: _decimalText(initial?.areaM2));
    final capacityCtrl = TextEditingController(
      text: initial?.capacityMax.toString() ?? '',
    );
    var status = initial?.status ?? BuildingStatus.empty;

    return showDialog<BuildingInput>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                initial == null ? 'Nouveau batiment' : 'Modifier le batiment',
              ),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DialogTextField(
                          controller: nameCtrl,
                          label: 'Nom ou identifiant',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: areaCtrl,
                          label: 'Superficie (m2)',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: capacityCtrl,
                          label: 'Capacite max',
                          keyboardType: TextInputType.number,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<BuildingStatus>(
                          initialValue: status,
                          decoration: const InputDecoration(
                            labelText: 'Statut',
                            border: OutlineInputBorder(),
                          ),
                          items: BuildingStatus.values
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => status = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(dialogContext).pop(
                      BuildingInput(
                        name: nameCtrl.text.trim(),
                        areaM2: _parseDouble(areaCtrl.text),
                        capacityMax: _parseInt(capacityCtrl.text),
                        status: status,
                      ),
                    );
                  },
                  child: Text(initial == null ? 'Creer' : 'Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<CreateLotInput?> _showCreateLotDialog({
    required List<PoultryType> poultryTypes,
    required List<Building> availableBuildings,
  }) async {
    if (poultryTypes.isEmpty) {
      _showError('Cree au moins un type de volaille avant de creer un lot.');
      return null;
    }
    if (availableBuildings.isEmpty) {
      _showError('Aucun batiment VIDE disponible pour accueillir un lot.');
      return null;
    }

    final formKey = GlobalKey<FormState>();
    final identifierCtrl = TextEditingController();
    final countCtrl = TextEditingController();
    final supplierCtrl = TextEditingController();
    var selectedType = poultryTypes.first;
    var selectedBuilding = availableBuildings.first;
    var selectedDate = DateTime.now();

    return showDialog<CreateLotInput>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Creer un lot'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DialogTextField(
                          controller: identifierCtrl,
                          label: 'Identifiant du lot',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<PoultryType>(
                          initialValue: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Type de volaille',
                            border: OutlineInputBorder(),
                          ),
                          items: poultryTypes
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    '${item.name} (${item.category.label})',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => selectedType = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<Building>(
                          initialValue: selectedBuilding,
                          decoration: const InputDecoration(
                            labelText: 'Batiment disponible',
                            border: OutlineInputBorder(),
                          ),
                          items: availableBuildings
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    '${item.name} (${item.capacityMax} sujets)',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => selectedBuilding = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        _DatePickerField(
                          label: 'Date d entree',
                          date: selectedDate,
                          onPick: () async {
                            final picked = await _pickDate(
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => selectedDate = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: countCtrl,
                          label: 'Nombre de sujets',
                          keyboardType: TextInputType.number,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: supplierCtrl,
                          label: 'Provenance / couvoir',
                          validator: _requiredValidator,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(dialogContext).pop(
                      CreateLotInput(
                        identifier: identifierCtrl.text.trim(),
                        poultryTypeId: selectedType.id,
                        buildingId: selectedBuilding.id,
                        entryDate: selectedDate,
                        initialBirdCount: _parseInt(countCtrl.text),
                        supplier: supplierCtrl.text.trim(),
                      ),
                    );
                  },
                  child: const Text('Creer le lot'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<CloseLotInput?> _showCloseLotDialog(FlockLot lot) {
    final formKey = GlobalKey<FormState>();
    final finalCountCtrl = TextEditingController(
      text: lot.currentBirdCount.toString(),
    );
    final finalWeightCtrl = TextEditingController();
    final totalEggsCtrl = TextEditingController();
    var exitReason = LotExitReason.slaughter;
    var exitDate = DateTime.now();

    return showDialog<CloseLotInput>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Cloturer ${lot.identifier}'),
              content: SizedBox(
                width: 430,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DatePickerField(
                          label: 'Date de sortie',
                          date: exitDate,
                          onPick: () async {
                            final picked = await _pickDate(
                              initialDate: exitDate,
                              firstDate: lot.entryDate,
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => exitDate = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: finalCountCtrl,
                          label: 'Nombre de sujets sortis',
                          keyboardType: TextInputType.number,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        if (lot.category == PoultryCategory.meat) ...[
                          _DialogTextField(
                            controller: finalWeightCtrl,
                            label: 'Poids moyen final (kg)',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<LotExitReason>(
                            initialValue: exitReason,
                            decoration: const InputDecoration(
                              labelText: 'Motif de sortie',
                              border: OutlineInputBorder(),
                            ),
                            items: LotExitReason.values
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => exitReason = value);
                            },
                          ),
                        ] else ...[
                          _DialogTextField(
                            controller: totalEggsCtrl,
                            label: 'Production totale d oeufs',
                            keyboardType: TextInputType.number,
                            validator: _requiredValidator,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(dialogContext).pop(
                      CloseLotInput(
                        lotId: lot.id,
                        exitDate: exitDate,
                        finalBirdCount: _parseInt(finalCountCtrl.text),
                        averageFinalWeightKg:
                            lot.category == PoultryCategory.meat
                            ? _parseDouble(finalWeightCtrl.text)
                            : null,
                        exitReason: lot.category == PoultryCategory.meat
                            ? exitReason
                            : null,
                        totalEggProduction:
                            lot.category == PoultryCategory.layer
                            ? _parseInt(totalEggsCtrl.text)
                            : null,
                      ),
                    );
                  },
                  child: const Text('Cloturer le lot'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<CreateDailyEntryInput?> _showDailyEntryDialog(FlockLot lot) {
    final formKey = GlobalKey<FormState>();
    final mortalityCtrl = TextEditingController(text: '0');
    final feedCtrl = TextEditingController();
    final waterCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final avgWeightCtrl = TextEditingController();
    final eggsCtrl = TextEditingController();
    var entryDate = DateTime.now();

    return showDialog<CreateDailyEntryInput>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Saisie quotidienne - ${lot.identifier}'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DatePickerField(
                          label: 'Date de saisie',
                          date: entryDate,
                          onPick: () async {
                            final picked = await _pickDate(
                              initialDate: entryDate,
                              firstDate: lot.entryDate,
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => entryDate = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: mortalityCtrl,
                          label: 'Nombre de morts du jour',
                          keyboardType: TextInputType.number,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        if (lot.category == PoultryCategory.meat)
                          _DialogTextField(
                            controller: avgWeightCtrl,
                            label: 'Poids moyen (kg)',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: _requiredValidator,
                          )
                        else
                          _DialogTextField(
                            controller: eggsCtrl,
                            label: 'Nombre d oeufs du jour',
                            keyboardType: TextInputType.number,
                            validator: _requiredValidator,
                          ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: feedCtrl,
                          label: 'Quantite d aliments (kg)',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: waterCtrl,
                          label: 'Quantite d eau (L)',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: notesCtrl,
                          label: 'Observations (optionnel)',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Les indicateurs sont enregistres avec la saisie du jour.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(dialogContext).pop(
                      CreateDailyEntryInput(
                        lotId: lot.id,
                        entryDate: entryDate,
                        dailyMortality: _parseInt(mortalityCtrl.text),
                        feedKg: _parseDouble(feedCtrl.text),
                        waterLiters: _parseDouble(waterCtrl.text),
                        notes: notesCtrl.text.trim(),
                        averageWeightKg: lot.category == PoultryCategory.meat
                            ? _parseDouble(avgWeightCtrl.text)
                            : null,
                        eggCount: lot.category == PoultryCategory.layer
                            ? _parseInt(eggsCtrl.text)
                            : null,
                      ),
                    );
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<AddJournalNoteInput?> _showJournalNoteDialog({
    required String lotId,
    required JournalEventType type,
  }) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(
      text: type == JournalEventType.vaccination ? 'Vaccination' : 'Alerte',
    );
    final descriptionCtrl = TextEditingController();
    var occurredAt = DateTime.now();

    return showDialog<AddJournalNoteInput>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Ajouter ${type.label.toLowerCase()}'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DatePickerField(
                          label: 'Date',
                          date: occurredAt,
                          onPick: () async {
                            final picked = await _pickDate(
                              initialDate: occurredAt,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => occurredAt = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: titleCtrl,
                          label: 'Titre',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        _DialogTextField(
                          controller: descriptionCtrl,
                          label: 'Description',
                          maxLines: 4,
                          validator: _requiredValidator,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(dialogContext).pop(
                      AddJournalNoteInput(
                        lotId: lotId,
                        type: type,
                        title: titleCtrl.text.trim(),
                        description: descriptionCtrl.text.trim(),
                        occurredAt: occurredAt,
                      ),
                    );
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<DateTime?> _pickDate({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.beetRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    try {
      await action();
      if (!mounted) return;
      _showSuccess(successMessage);
    } catch (error) {
      if (!mounted) return;
      _showError(_friendlyError(error));
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.beetRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _friendlyError(Object error) {
    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return 'Acces refuse a Firestore. Verifie que l utilisateur est connecte et que les regles sont deployees.';
      }
      if (error.message != null && error.message!.trim().isNotEmpty) {
        return error.message!.trim();
      }
    }
    final text = error.toString().replaceFirst('Exception: ', '').trim();
    return text.isEmpty ? 'Une erreur est survenue.' : text;
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Champ requis';
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _decimalText(double? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  double _parseDouble(String value) {
    final normalized = value.replaceAll(',', '.').trim();
    return double.tryParse(normalized) ?? 0;
  }

  int _parseInt(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  Color _eventColor(JournalEventType type) {
    switch (type) {
      case JournalEventType.entry:
        return AppColors.green;
      case JournalEventType.dailyEntry:
        return AppColors.blue;
      case JournalEventType.vaccination:
        return AppColors.amber;
      case JournalEventType.alert:
        return AppColors.beetRed;
      case JournalEventType.closure:
        return AppColors.muted;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: t.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: t.mutedColor)),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded),
              label: Text(actionLabel!),
            ),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: t.textColor,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: TextStyle(color: t.mutedColor)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.green),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: t.textColor,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: t.mutedColor)),
        ],
      ),
    );
  }
}

class _PoultryTypeCard extends StatelessWidget {
  final PoultryType item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PoultryTypeCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: t.textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
              _StatusBadge(
                label: item.category.label,
                color: item.category == PoultryCategory.meat
                    ? AppColors.green
                    : AppColors.amber,
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                label: 'Temperature',
                value:
                    '${item.targetTempMin.toStringAsFixed(1)} - ${item.targetTempMax.toStringAsFixed(1)} C',
              ),
              _MetricChip(
                label: 'Humidite',
                value:
                    '${item.targetHumidityMin.toStringAsFixed(0)} - ${item.targetHumidityMax.toStringAsFixed(0)} %',
              ),
              _MetricChip(
                label: 'Densite',
                value: '${item.recommendedDensity.toStringAsFixed(1)} /m2',
              ),
              _MetricChip(
                label: 'Lumiere',
                value: '${item.recommendedLightHours.toStringAsFixed(1)} h',
              ),
              _MetricChip(
                label: 'Duree type',
                value: '${item.typicalDurationDays} j',
              ),
              _MetricChip(
                label: item.category.targetMetricLabel,
                value: item.category == PoultryCategory.meat
                    ? '${item.targetValue.toStringAsFixed(2)} kg'
                    : '${item.targetValue.toStringAsFixed(0)} j',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BuildingCard extends StatelessWidget {
  final Building item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BuildingCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    final color = item.status == BuildingStatus.active
        ? AppColors.green
        : item.status == BuildingStatus.disinfecting
        ? AppColors.amber
        : AppColors.blue;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: t.textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
              _StatusBadge(label: item.status.label, color: color),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                label: 'Superficie',
                value: '${item.areaM2.toStringAsFixed(1)} m2',
              ),
              _MetricChip(
                label: 'Capacite',
                value: '${item.capacityMax} sujets',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LotCard extends StatelessWidget {
  final FlockLot lot;
  final VoidCallback onClose;
  final VoidCallback onJournal;
  final VoidCallback onTrack;

  const _LotCard({
    required this.lot,
    required this.onClose,
    required this.onJournal,
    required this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lot.identifier,
                  style: TextStyle(
                    color: t.textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
              _StatusBadge(
                label: lot.category.label,
                color: lot.category == PoultryCategory.meat
                    ? AppColors.green
                    : AppColors.amber,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${lot.poultryTypeName} - ${lot.buildingName}',
            style: TextStyle(color: t.mutedColor),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(label: 'Entree', value: _date(lot.entryDate)),
              _MetricChip(
                label: 'Sujets initiaux',
                value: '${lot.initialBirdCount}',
              ),
              _MetricChip(label: 'Vivants', value: '${lot.currentBirdCount}'),
              _MetricChip(label: 'Morts cumules', value: '${lot.totalDeaths}'),
              if (lot.supplier.isNotEmpty)
                _MetricChip(label: 'Provenance', value: lot.supplier),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onTrack,
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Saisir'),
              ),
              OutlinedButton.icon(
                onPressed: onJournal,
                icon: const Icon(Icons.history_rounded),
                label: const Text('Journal'),
              ),
              OutlinedButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.task_alt_rounded),
                label: const Text('Cloturer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _date(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}

class _ClosedLotCard extends StatelessWidget {
  final FlockLot lot;
  final VoidCallback onJournal;

  const _ClosedLotCard({required this.lot, required this.onJournal});

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    final summary = lot.summary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lot.identifier,
                  style: TextStyle(
                    color: t.textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
              const _StatusBadge(label: 'Cloture', color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${lot.poultryTypeName} - ${lot.buildingName}',
            style: TextStyle(color: t.mutedColor),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (summary?.exitDate != null)
                _MetricChip(label: 'Sortie', value: _date(summary!.exitDate!)),
              _MetricChip(
                label: 'Sujets sortis',
                value: '${summary?.finalBirdCount ?? lot.currentBirdCount}',
              ),
              _MetricChip(
                label: 'Mortalite cumulee',
                value:
                    '${(summary?.cumulativeMortalityRate ?? 0).toStringAsFixed(1)} %',
              ),
              if (lot.category == PoultryCategory.meat)
                _MetricChip(
                  label: 'Poids final',
                  value:
                      '${(summary?.averageFinalWeightKg ?? 0).toStringAsFixed(2)} kg',
                )
              else
                _MetricChip(
                  label: 'Production totale',
                  value: '${summary?.totalEggProduction ?? 0} oeufs',
                ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onJournal,
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Consulter le journal'),
          ),
        ],
      ),
    );
  }

  String _date(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}

class _TrackingLotCard extends StatelessWidget {
  final FlockLot lot;
  final Stream<List<DailyEntry>> entriesStream;
  final VoidCallback onTrack;
  final VoidCallback onHistory;
  final VoidCallback onJournal;

  const _TrackingLotCard({
    required this.lot,
    required this.entriesStream,
    required this.onTrack,
    required this.onHistory,
    required this.onJournal,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.borderColor),
      ),
      child: StreamBuilder<List<DailyEntry>>(
        stream: entriesStream,
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const <DailyEntry>[];
          final latest = entries.isEmpty ? null : entries.first;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lot.identifier,
                      style: TextStyle(
                        color: t.textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _StatusBadge(
                    label: lot.category.label,
                    color: lot.category == PoultryCategory.meat
                        ? AppColors.green
                        : AppColors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${lot.poultryTypeName} - ${lot.buildingName}',
                style: TextStyle(color: t.mutedColor),
              ),
              const SizedBox(height: 14),
              if (latest == null)
                const Text('Aucune saisie pour ce lot pour le moment.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetricChip(
                      label: 'Derniere saisie',
                      value: _date(latest.entryDate),
                    ),
                    _MetricChip(
                      label: 'Mortalite cumulee',
                      value:
                          '${latest.cumulativeMortalityRate.toStringAsFixed(1)} %',
                    ),
                    if (lot.category == PoultryCategory.meat) ...[
                      _MetricChip(
                        label: 'Poids',
                        value:
                            '${(latest.averageWeightKg ?? 0).toStringAsFixed(2)} kg',
                      ),
                      _MetricChip(
                        label: 'GMQ',
                        value:
                            '${(latest.dailyWeightGainG ?? 0).toStringAsFixed(1)} g/j',
                      ),
                      _MetricChip(
                        label: 'IC',
                        value: (latest.feedConversionRatio ?? 0)
                            .toStringAsFixed(2),
                      ),
                    ] else ...[
                      _MetricChip(
                        label: 'Oeufs',
                        value: '${latest.eggCount ?? 0}',
                      ),
                      _MetricChip(
                        label: 'Taux de ponte',
                        value: '${(latest.layRate ?? 0).toStringAsFixed(1)} %',
                      ),
                      _MetricChip(
                        label: 'Pic',
                        value:
                            '${(latest.peakLayRate ?? 0).toStringAsFixed(1)} %',
                      ),
                    ],
                  ],
                ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: onTrack,
                    icon: const Icon(Icons.post_add_rounded),
                    label: const Text('Nouvelle saisie'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onHistory,
                    icon: const Icon(Icons.analytics_rounded),
                    label: const Text('Historique'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onJournal,
                    icon: const Icon(Icons.history_toggle_off_rounded),
                    label: const Text('Journal'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _date(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}

class _LotOverviewTile extends StatelessWidget {
  final FlockLot lot;
  final VoidCallback onTrack;
  final VoidCallback onJournal;

  const _LotOverviewTile({
    required this.lot,
    required this.onTrack,
    required this.onJournal,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lot.identifier,
                  style: TextStyle(
                    color: t.textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${lot.poultryTypeName} - ${lot.buildingName}',
                  style: TextStyle(color: t.mutedColor, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  '${lot.currentBirdCount} sujets vivants',
                  style: TextStyle(color: t.textColor),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              IconButton(
                tooltip: 'Saisir',
                onPressed: onTrack,
                icon: const Icon(Icons.edit_note_rounded),
              ),
              IconButton(
                tooltip: 'Journal',
                onPressed: onJournal,
                icon: const Icon(Icons.history_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: t.textColor, fontSize: 12),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onPick;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_rounded),
        ),
        child: Text('$day/$month/${date.year}'),
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const _DialogTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, color: AppColors.green, size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(color: t.textColor, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: t.mutedColor),
          ),
        ],
      ),
    );
  }
}
