import 'package:flutter/material.dart';

import '../../../../shared/presentation/theme/app_colors.dart';
import '../../../../shared/presentation/theme/theme_provider.dart';
import '../../../../shared/presentation/widgets/form_section.dart';
import '../../../gestions_des_lots_des_volailles/domain/entities/flock_lot.dart';
import '../../data/repositories/vaccination_repository_impl.dart';
import '../../data/services/vaccination_service.dart';
import '../../domain/entities/vaccination_plan.dart';
import '../../domain/inputs/create_vaccination_plan_input.dart';
import '../../domain/inputs/record_vaccination_input.dart';

class VaccinationsScreen extends StatefulWidget {
  final bool showShell;

  const VaccinationsScreen({this.showShell = true, super.key});

  @override
  State<VaccinationsScreen> createState() => _VaccinationsScreenState();
}

class _VaccinationsScreenState extends State<VaccinationsScreen> {
  final VaccinationRepositoryImpl _repository = VaccinationRepositoryImpl(
    VaccinationService(),
  );

  String? _selectedLotId;

  static const List<String> _administrationRoutes = [
    'Orale',
    'Intramusculaire',
    'Sous-cutanee',
    'Oculaire',
    'Eau de boisson',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.instance;
    final content = _buildContent(theme);

    if (!widget.showShell) {
      return Container(color: theme.bgColor, child: content);
    }

    return Scaffold(
      backgroundColor: theme.bgColor,
      body: SafeArea(
        child: Column(
          children: [
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
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.vaccines_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Vaccinations',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Suivi des plans et rappels',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeProvider theme) {
    return StreamBuilder<List<FlockLot>>(
      stream: _repository.watchActiveLots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeLots = snapshot.data ?? const <FlockLot>[];
        if (activeLots.isNotEmpty &&
            (_selectedLotId == null ||
                activeLots.every((lot) => lot.id != _selectedLotId))) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && activeLots.isNotEmpty) {
              setState(() => _selectedLotId = activeLots.first.id);
            }
          });
        }

        final selectedLot = _selectedLot(activeLots);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (activeLots.isEmpty)
              _EmptyLotState(theme: theme)
            else ...[
              _LotSelectorCard(
                theme: theme,
                lots: activeLots,
                selectedLotId: _selectedLotId ?? activeLots.first.id,
                onLotSelected: (lotId) =>
                    setState(() => _selectedLotId = lotId),
              ),
              const SizedBox(height: 16),
              if (selectedLot != null) ...[
                _SelectedLotSummary(theme: theme, lot: selectedLot),
                const SizedBox(height: 16),
                _ActionPanel(
                  theme: theme,
                  onPlan: () => _openPlanDialog(selectedLot),
                  onRecord: () => _openRecordDialog(selectedLot),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<VaccinationPlan>>(
                  stream: _repository.watchPlans(selectedLot.id),
                  builder: (context, plansSnapshot) {
                    final plans =
                        plansSnapshot.data ?? const <VaccinationPlan>[];
                    final pendingPlans = plans
                        .where((plan) => !plan.isCompleted)
                        .toList();
                    final completedPlans = plans
                        .where((plan) => plan.isCompleted)
                        .toList();

                    return Column(
                      children: [
                        _OverviewStrip(
                          theme: theme,
                          lot: selectedLot,
                          pendingCount: pendingPlans.length,
                          completedCount: completedPlans.length,
                        ),
                        const SizedBox(height: 16),
                        _PlansCard(theme: theme, plans: pendingPlans),
                        const SizedBox(height: 16),
                        _CompletedVaccinationsCard(
                          theme: theme,
                          plans: completedPlans,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  FlockLot? _selectedLot(List<FlockLot> lots) {
    if (lots.isEmpty) return null;
    if (_selectedLotId == null) return lots.first;
    for (final lot in lots) {
      if (lot.id == _selectedLotId) return lot;
    }
    return lots.first;
  }

  Future<void> _openPlanDialog(FlockLot lot) async {
    final formKey = GlobalKey<FormState>();
    final vaccineCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    var plannedDate = DateTime.now().add(const Duration(days: 1));
    var plannedTime = const TimeOfDay(hour: 8, minute: 0);
    var route = _administrationRoutes.first;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemeProvider.instance.dialogBg,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Planifier une vaccination',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: ThemeProvider.instance.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lot.identifier} - ${lot.poultryTypeName}',
                        style: TextStyle(
                          color: ThemeProvider.instance.mutedColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DecoratedFormField(
                        controller: vaccineCtrl,
                        label: 'Nom du vaccin',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Champ requis'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DecoratedDropdown<String>(
                        label: 'Voie d\'administration',
                        value: route,
                        items: _administrationRoutes
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setSheetState(() => route = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DecoratedFormField(
                        controller: doseCtrl,
                        label: 'Dose par sujet',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final parsed = double.tryParse(
                            value?.replaceAll(',', '.') ?? '',
                          );
                          if (parsed == null || parsed <= 0) {
                            return 'Dose invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _DateField(
                        label: 'Date prévue',
                        value: plannedDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: plannedDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 1),
                            ),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setSheetState(() => plannedDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _TimeField(
                        label: 'Heure de rappel',
                        value: plannedTime,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: plannedTime,
                          );
                          if (picked != null) {
                            setSheetState(() => plannedTime = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Annuler'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                if (!formKey.currentState!.validate()) return;
                                Navigator.of(dialogContext).pop(true);
                              },
                              child: const Text('Planifier'),
                            ),
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
    );

    if (result != true || !mounted) return;

    final plannedAt = DateTime(
      plannedDate.year,
      plannedDate.month,
      plannedDate.day,
      plannedTime.hour,
      plannedTime.minute,
    );

    await _runAction(
      () => _repository.createPlan(
        CreateVaccinationPlanInput(
          lotId: lot.id,
          lotIdentifier: lot.identifier,
          buildingName: lot.buildingName,
          poultryTypeName: lot.poultryTypeName,
          plannedDate: plannedAt,
          vaccineName: vaccineCtrl.text.trim(),
          administrationRoute: route,
          dosePerSubject: double.parse(doseCtrl.text.replaceAll(',', '.')),
        ),
      ),
      successMessage: 'Calendrier vaccinal enregistre.',
    );
  }

  Future<void> _openRecordDialog(FlockLot lot) async {
    final plans = await _repository
        .watchPlans(lot.id)
        .first
        .catchError((_) => <VaccinationPlan>[]);
    final pendingPlans = plans.where((plan) => !plan.isCompleted).toList();
    if (pendingPlans.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crée d’abord un calendrier vaccinal.')),
      );
      return;
    }

    var selectedPlan = pendingPlans.first;
    final actualDoseCtrl = TextEditingController(
      text: selectedPlan.dosePerSubject.toString(),
    );
    final subjectsCtrl = TextEditingController(
      text: lot.currentBirdCount.toString(),
    );
    var actualDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemeProvider.instance.dialogBg,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valider une vaccination',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: ThemeProvider.instance.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lot.identifier} - ${lot.poultryTypeName}',
                        style: TextStyle(
                          color: ThemeProvider.instance.mutedColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DecoratedDropdown<String>(
                        label: 'Vaccination planifiee',
                        value: selectedPlan.id,
                        items: pendingPlans
                            .map(
                              (plan) => DropdownMenuItem(
                                value: plan.id,
                                child: Text(
                                  '${plan.vaccineName} - ${_formatDate(plan.plannedDate.toDate())}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          final plan = pendingPlans.firstWhere(
                            (element) => element.id == value,
                            orElse: () => pendingPlans.first,
                          );
                          setSheetState(() {
                            selectedPlan = plan;
                            actualDoseCtrl.text = plan.dosePerSubject
                                .toString();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _DateField(
                        label: 'Date reelle',
                        value: actualDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: actualDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setSheetState(() => actualDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DecoratedFormField(
                        controller: actualDoseCtrl,
                        label: 'Dose administrée',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final parsed = double.tryParse(
                            value?.replaceAll(',', '.') ?? '',
                          );
                          if (parsed == null || parsed <= 0) {
                            return 'Dose invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DecoratedFormField(
                        controller: subjectsCtrl,
                        label: 'Nombre de sujets vaccinés',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final parsed = int.tryParse(value ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Nombre invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Annuler'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                if (!formKey.currentState!.validate()) return;
                                Navigator.of(dialogContext).pop(true);
                              },
                              child: const Text('Valider'),
                            ),
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
    );

    if (result != true || !mounted) return;

    await _runAction(
      () => _repository.recordVaccination(
        RecordVaccinationInput(
          lotId: lot.id,
          planId: selectedPlan.id,
          actualDate: actualDate,
          actualDosePerSubject: double.parse(
            actualDoseCtrl.text.replaceAll(',', '.'),
          ),
          vaccinatedSubjects: int.parse(subjectsCtrl.text),
        ),
      ),
      successMessage: 'Vaccination ajoutee au journal du lot.',
    );
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }
}

class _HeaderCard extends StatelessWidget {
  final ThemeProvider theme;
  final int activeLotsCount;

  const _HeaderCard({required this.theme, required this.activeLotsCount});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.green.withValues(alpha: 0.96),
            AppColors.green.withValues(alpha: 0.72),
            const Color(0xFF183D35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -18,
            bottom: -24,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: const Icon(
                        Icons.vaccines_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suivi des vaccinations',
                            style: textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pilote les plans, les rappels et les vaccinations validées dans une vue plus claire et plus rapide à lire.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MiniStatPill(
                      label: 'Lots actifs',
                      value: '$activeLotsCount',
                    ),
                    const _MiniStatPill(
                      label: 'Actions rapides',
                      value: 'Planifier / valider',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatPill extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label · ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLotState extends StatelessWidget {
  final ThemeProvider theme;

  const _EmptyLotState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.hourglass_empty_rounded,
              size: 32,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Aucun lot actif',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crée ou ouvre un lot actif pour planifier et enregistrer des vaccinations.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.mutedColor, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _LotSelectorCard extends StatelessWidget {
  final ThemeProvider theme;
  final List<FlockLot> lots;
  final String selectedLotId;
  final ValueChanged<String> onLotSelected;

  const _LotSelectorCard({
    required this.theme,
    required this.lots,
    required this.selectedLotId,
    required this.onLotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_hospital_outlined,
                  size: 20,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lot actif',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: theme.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sélection rapide',
                      style: TextStyle(color: theme.mutedColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: lots
                .map(
                  (lot) => ChoiceChip(
                    label: Text(lot.identifier),
                    selected: selectedLotId == lot.id,
                    onSelected: (_) => onLotSelected(lot.id),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SelectedLotSummary extends StatelessWidget {
  final ThemeProvider theme;
  final FlockLot lot;

  const _SelectedLotSummary({required this.theme, required this.lot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.groups_rounded, color: AppColors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.identifier,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: theme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lot.poultryTypeName} - ${lot.buildingName}',
                      style: TextStyle(color: theme.mutedColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                label: 'Effectif actuel',
                value: '${lot.currentBirdCount}',
              ),
              _InfoChip(label: 'Provenance', value: lot.provenance),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final ThemeProvider theme;
  final VoidCallback onPlan;
  final VoidCallback onRecord;

  const _ActionPanel({
    required this.theme,
    required this.onPlan,
    required this.onRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onPlan,
                icon: const Icon(Icons.event_available_outlined),
                label: const Text('Planifier'),
              ),
              OutlinedButton.icon(
                onPressed: onRecord,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Valider une vaccination'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewStrip extends StatelessWidget {
  final ThemeProvider theme;
  final FlockLot lot;
  final int pendingCount;
  final int completedCount;

  const _OverviewStrip({
    required this.theme,
    required this.lot,
    required this.pendingCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricCard(
              label: 'En attente',
              value: '$pendingCount',
              accentColor: const Color(0xFFE08B21),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MetricCard(
              label: 'Validées',
              value: '$completedCount',
              accentColor: AppColors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MetricCard(
              label: 'Lot',
              value: lot.identifier,
              accentColor: theme.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: accentColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlansCard extends StatelessWidget {
  final ThemeProvider theme;
  final List<VaccinationPlan> plans;

  const _PlansCard({required this.theme, required this.plans});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Calendrier vaccinal',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: theme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (plans.isEmpty)
            Text(
              'Aucune vaccination planifiee pour ce lot.',
              style: TextStyle(color: theme.mutedColor),
            )
          else
            ...plans.map(
              (plan) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.bgColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              plan.vaccineName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: theme.textColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _formatDate(plan.plannedDate.toDate()),
                              style: const TextStyle(
                                color: AppColors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${plan.administrationRoute} - ${plan.dosePerSubject} par sujet',
                        style: TextStyle(color: theme.mutedColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }
}

class _CompletedVaccinationsCard extends StatelessWidget {
  final ThemeProvider theme;
  final List<VaccinationPlan> plans;

  const _CompletedVaccinationsCard({required this.theme, required this.plans});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_outlined,
                  size: 20,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Vaccinations validées',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: theme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (plans.isEmpty)
            Text(
              'Aucune vaccination effectuee pour le moment.',
              style: TextStyle(color: theme.mutedColor),
            )
          else
            ...plans.map(
              (plan) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.bgColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              plan.vaccineName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: theme.textColor,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.green,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Realisee le ${_formatDate(plan.actualDate?.toDate() ?? plan.plannedDate.toDate())} - ${plan.vaccinatedSubjects ?? '-'} sujets - ${plan.actualDosePerSubject ?? plan.dosePerSubject} par sujet',
                        style: TextStyle(color: theme.mutedColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text('$day/$month/${local.year}'),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay value;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text('$hour:$minute'),
      ),
    );
  }
}
