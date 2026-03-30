// lib/features/farm_config/tabs/config_tab.dart
//
// Wizard de configuration entièrement libre.
// Étape 1 : Informations générales (nom, type texte libre, objectif texte libre)
// Étape 2 : Bâtiment (nombre de sujets, superficie)
// Étape 3 : Seuils capteurs
// Étape 4 : Automatismes

import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/models.dart';
import '../widgets/shared_widgets.dart';
import 'dashboard_tab.dart' show FarmSummaryCard;

class ConfigTab extends StatelessWidget {
  final SystemConfig cfg;
  final SystemState sysState;
  final int wizardStep;
  final TextEditingController farmNameCtrl;
  final TextEditingController poultryTypeCtrl;
  final TextEditingController objectiveCtrl;
  final TextEditingController birdCtrl;
  final TextEditingController surfaceCtrl;
  final void Function(int step) onStepChange;
  final void Function(String field, dynamic val) onFieldChange;
  final VoidCallback onLaunch;

  const ConfigTab({
    required this.cfg,
    required this.sysState,
    required this.wizardStep,
    required this.farmNameCtrl,
    required this.poultryTypeCtrl,
    required this.objectiveCtrl,
    required this.birdCtrl,
    required this.surfaceCtrl,
    required this.onStepChange,
    required this.onFieldChange,
    required this.onLaunch,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (cfg.isConfigured && sysState != SystemState.idle) {
      return _ConfigSummary(cfg: cfg);
    }
    return Column(
      children: [
        _WizardProgressBar(step: wizardStep),
        Expanded(child: _wizardContent(context)),
      ],
    );
  }

  Widget _wizardContent(BuildContext context) {
    switch (wizardStep) {
      case 0:
        return _StepGeneral(
          cfg: cfg,
          farmNameCtrl: farmNameCtrl,
          poultryTypeCtrl: poultryTypeCtrl,
          objectiveCtrl: objectiveCtrl,
          onFieldChange: onFieldChange,
          onNext: () => onStepChange(1),
        );
      case 1:
        return _StepBuilding(
          cfg: cfg,
          birdCtrl: birdCtrl,
          surfaceCtrl: surfaceCtrl,
          onFieldChange: onFieldChange,
          onBack: () => onStepChange(0),
          onNext: () => onStepChange(2),
        );
      case 2:
        return _StepThresholds(
          cfg: cfg,
          onFieldChange: onFieldChange,
          onBack: () => onStepChange(1),
          onNext: () => onStepChange(3),
        );
      case 3:
        return _StepAutomation(
          cfg: cfg,
          onFieldChange: onFieldChange,
          onBack: () => onStepChange(2),
          onLaunch: onLaunch,
        );
      default:
        return _StepGeneral(
          cfg: cfg,
          farmNameCtrl: farmNameCtrl,
          poultryTypeCtrl: poultryTypeCtrl,
          objectiveCtrl: objectiveCtrl,
          onFieldChange: onFieldChange,
          onNext: () => onStepChange(1),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// Résumé config (lecture seule quand système actif)
// ─────────────────────────────────────────────────────────────────

class _ConfigSummary extends StatelessWidget {
  final SystemConfig cfg;
  const _ConfigSummary({required this.cfg});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.green.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cfg.farmName,
                      style: const TextStyle(
                        color: AppColors.dark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      cfg.poultryType,
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cfg.objective.isNotEmpty
                                ? cfg.objective
                                : 'Non renseigné',
                            style: const TextStyle(
                              color: AppColors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ACTIF',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.yellow.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.yellow.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.yellow,
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Pour modifier la configuration, arrête d'abord le système depuis le tableau de bord.",
                  style: TextStyle(
                    color: AppColors.dark.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('PARAMÈTRES ACTIFS'),
        const SizedBox(height: 12),
        FarmSummaryCard(cfg: cfg),
        const SizedBox(height: 16),
        const SectionLabel('AUTOMATISMES'),
        const SizedBox(height: 12),
        _AutomationSummary(cfg: cfg),
      ],
    ),
  );
}

class _AutomationSummary extends StatelessWidget {
  final SystemConfig cfg;
  const _AutomationSummary({required this.cfg});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'label': 'Ventilation',
        'val': cfg.autoVentilation,
        'icon': Icons.air_outlined,
        'color': AppColors.blue,
      },
      {
        'label': 'Chauffage',
        'val': cfg.autoHeating,
        'icon': Icons.local_fire_department_rounded,
        'color': AppColors.green,
      },
      {
        'label': 'Éclairage',
        'val': cfg.autoLighting,
        'icon': Icons.light_mode_rounded,
        'color': AppColors.yellow,
      },
      {
        'label': 'Alimentation',
        'val': cfg.autoFeeding,
        'icon': Icons.restaurant_rounded,
        'color': AppColors.green,
      },
      {
        'label': 'Abreuvement',
        'val': cfg.autoWatering,
        'icon': Icons.water_drop_outlined,
        'color': AppColors.blue,
      },
    ];
    return Column(
      children: items.map((a) {
        final on = a['val'] as bool;
        final color = a['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.dark.withOpacity(0.07)),
          ),
          child: Row(
            children: [
              Icon(
                a['icon'] as IconData,
                color: on ? color : AppColors.muted,
                size: 17,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  a['label'] as String,
                  style: TextStyle(
                    color: on ? AppColors.dark : AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: (on ? AppColors.green : AppColors.muted).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  on ? 'ACTIVÉ' : 'DÉSACTIVÉ',
                  style: TextStyle(
                    color: on ? AppColors.green : AppColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Barre de progression wizard
// ─────────────────────────────────────────────────────────────────

class _WizardProgressBar extends StatelessWidget {
  final int step;
  const _WizardProgressBar({required this.step});
  static const _steps = ['Général', 'Bâtiment', 'Seuils', 'Automatismes'];

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(
      children: List.generate(_steps.length, (i) {
        final done = i < step;
        final active = i == step;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3,
                      decoration: BoxDecoration(
                        color: done || active
                            ? AppColors.green
                            : AppColors.dark.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _steps[i],
                      style: TextStyle(
                        color: active
                            ? AppColors.green
                            : done
                            ? AppColors.green
                            : AppColors.muted,
                        fontSize: 9,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < _steps.length - 1) const SizedBox(width: 6),
            ],
          ),
        );
      }),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// Étape 1 — Informations générales (ENTIÈREMENT LIBRE)
// ─────────────────────────────────────────────────────────────────

class _StepGeneral extends StatefulWidget {
  final SystemConfig cfg;
  final TextEditingController farmNameCtrl;
  final TextEditingController poultryTypeCtrl;
  final TextEditingController objectiveCtrl;
  final void Function(String, dynamic) onFieldChange;
  final VoidCallback onNext;

  const _StepGeneral({
    required this.cfg,
    required this.farmNameCtrl,
    required this.poultryTypeCtrl,
    required this.objectiveCtrl,
    required this.onFieldChange,
    required this.onNext,
  });

  @override
  State<_StepGeneral> createState() => _StepGeneralState();
}

class _StepGeneralState extends State<_StepGeneral> {
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepTitle(
          'Mon élevage',
          'Décris ton élevage librement selon tes besoins.',
        ),
        const SizedBox(height: 24),

        // Nom de l'élevage
        const FieldLabel('NOM DE L\'ÉLEVAGE'),
        const SizedBox(height: 7),
        KiwoTextField(
          controller: widget.farmNameCtrl,
          hint: '',
          suffix: '',
          keyboard: TextInputType.text,
          onChanged: (v) => widget.onFieldChange('farmName', v),
        ),
        const SizedBox(height: 16),

        // Type de volaille (texte libre)
        const FieldLabel('TYPE DE VOLAILLE'),
        const SizedBox(height: 7),
        KiwoTextField(
          controller: widget.poultryTypeCtrl,
          hint: '',
          suffix: '',
          keyboard: TextInputType.text,
          onChanged: (v) => widget.onFieldChange('poultryType', v),
        ),
        const SizedBox(height: 16),

        // Objectif de production
        const FieldLabel('OBJECTIF DE PRODUCTION'),
        const SizedBox(height: 7),
        KiwoTextField(
          controller: widget.objectiveCtrl,
          hint: '',
          suffix: '',
          keyboard: TextInputType.text,
          onChanged: (v) => widget.onFieldChange('objective', v),
        ),

        const SizedBox(height: 28),
        NextButton(
          'Suivant',
          enabled:
              widget.farmNameCtrl.text.trim().isNotEmpty &&
              widget.poultryTypeCtrl.text.trim().isNotEmpty &&
              widget.objectiveCtrl.text.trim().isNotEmpty,
          onTap: widget.onNext,
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// Étape 2 — Bâtiment
// ─────────────────────────────────────────────────────────────────

class _StepBuilding extends StatelessWidget {
  final SystemConfig cfg;
  final TextEditingController birdCtrl, surfaceCtrl;
  final void Function(String, dynamic) onFieldChange;
  final VoidCallback onBack, onNext;

  const _StepBuilding({
    required this.cfg,
    required this.birdCtrl,
    required this.surfaceCtrl,
    required this.onFieldChange,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepTitle(
          'Ton bâtiment',
          'Renseigne les informations sur ton installation.',
        ),
        const SizedBox(height: 20),
        const FieldLabel('NOMBRE DE SUJETS'),
        const SizedBox(height: 7),
        KiwoTextField(
          controller: birdCtrl,
          hint: 'ex: 500',
          icon: Icons.groups_rounded,
          suffix: 'sujets',
          keyboard: TextInputType.number,
          onChanged: (v) => onFieldChange('birdCount', int.tryParse(v) ?? 0),
        ),
        const SizedBox(height: 16),
        const FieldLabel('SUPERFICIE DU BÂTIMENT'),
        const SizedBox(height: 7),
        KiwoTextField(
          controller: surfaceCtrl,
          hint: 'ex: 200',
          icon: Icons.square_foot_rounded,
          suffix: 'm²',
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) => onFieldChange('surfaceM2', double.tryParse(v) ?? 0),
        ),
        if (cfg.birdCount > 0 && cfg.surfaceM2 > 0) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.07),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.green.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.green,
                  size: 15,
                ),
                const SizedBox(width: 10),
                Text(
                  'Densité : ${(cfg.birdCount / cfg.surfaceM2).toStringAsFixed(1)} sujets/m²',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),
        Row(
          children: [
            WizardBackButton(onTap: onBack),
            const SizedBox(width: 12),
            Expanded(
              child: NextButton(
                'Suivant',
                enabled: cfg.birdCount > 0 && cfg.surfaceM2 > 0,
                onTap: onNext,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// Étape 3 — Seuils capteurs
// ─────────────────────────────────────────────────────────────────

class _StepThresholds extends StatelessWidget {
  final SystemConfig cfg;
  final void Function(String, dynamic) onFieldChange;
  final VoidCallback onBack, onNext;

  const _StepThresholds({
    required this.cfg,
    required this.onFieldChange,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepTitle(
          'Seuils des capteurs',
          'Configure les seuils selon les besoins de ton élevage.',
        ),
        const SizedBox(height: 18),
        ThresholdCard(
          icon: Icons.thermostat_rounded,
          label: 'TEMPÉRATURE',
          unit: '°C',
          color: AppColors.green,
          minVal: cfg.tempMin,
          maxVal: cfg.tempMax,
          absMin: 0,
          absMax: 50,
          onMinChanged: (v) => onFieldChange('tempMin', v),
          onMaxChanged: (v) => onFieldChange('tempMax', v),
        ),
        const SizedBox(height: 10),
        ThresholdCard(
          icon: Icons.water_drop_rounded,
          label: 'HUMIDITÉ',
          unit: '%',
          color: AppColors.blue,
          minVal: cfg.humMin,
          maxVal: cfg.humMax,
          absMin: 0,
          absMax: 100,
          onMinChanged: (v) => onFieldChange('humMin', v),
          onMaxChanged: (v) => onFieldChange('humMax', v),
        ),
        const SizedBox(height: 10),
        SingleThresholdCard(
          icon: Icons.air_rounded,
          label: 'CO₂ MAX',
          unit: 'ppm',
          color: AppColors.muted,
          value: cfg.co2Max,
          min: 500,
          max: 5000,
          onChanged: (v) => onFieldChange('co2Max', v),
          description: 'Alerte déclenchée au-dessus de ce seuil.',
        ),
        const SizedBox(height: 10),
        SingleThresholdCard(
          icon: Icons.science_rounded,
          label: 'AMMONIAC MAX',
          unit: 'ppm',
          color: AppColors.green,
          value: cfg.ammoniacMax,
          min: 0,
          max: 50,
          onChanged: (v) => onFieldChange('ammoniacMax', v),
          description: 'Seuil critique pour la santé de tes volailles.',
        ),
        const SizedBox(height: 10),
        SingleThresholdCard(
          icon: Icons.wb_sunny_rounded,
          label: 'ÉCLAIRAGE / JOUR',
          unit: 'h',
          color: AppColors.yellow,
          value: cfg.lightHours,
          min: 0,
          max: 24,
          onChanged: (v) => onFieldChange('lightHours', v),
          description: 'Heures de lumière par jour.',
        ),
        const SizedBox(height: 10),
        SingleThresholdCard(
          icon: Icons.opacity_rounded,
          label: "ALERTE NIVEAU D'EAU",
          unit: '%',
          color: AppColors.blue,
          value: cfg.waterAlertPct,
          min: 0,
          max: 100,
          onChanged: (v) => onFieldChange('waterAlertPct', v),
          description: 'Alerte si le niveau descend en dessous.',
        ),
        const SizedBox(height: 10),
        SingleThresholdCard(
          icon: Icons.restaurant_rounded,
          label: 'ALERTE NOURRITURE',
          unit: '%',
          color: AppColors.beetRed,
          value: cfg.foodAlertPct,
          min: 0,
          max: 100,
          onChanged: (v) => onFieldChange('foodAlertPct', v),
          description: 'Alerte si le stock descend en dessous.',
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            WizardBackButton(onTap: onBack),
            const SizedBox(width: 12),
            Expanded(
              child: NextButton('Suivant', enabled: true, onTap: onNext),
            ),
          ],
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// Étape 4 — Automatismes
// ─────────────────────────────────────────────────────────────────

class _StepAutomation extends StatelessWidget {
  final SystemConfig cfg;
  final void Function(String, dynamic) onFieldChange;
  final VoidCallback onBack, onLaunch;

  const _StepAutomation({
    required this.cfg,
    required this.onFieldChange,
    required this.onBack,
    required this.onLaunch,
  });

  static const _items = [
    {
      'key': 'autoVentilation',
      'label': 'Ventilation automatique',
      'desc': 'Déclenche si CO₂ ou NH₃ dépasse le seuil.',
      'icon': Icons.air_outlined,
      'color': AppColors.blue,
    },
    {
      'key': 'autoHeating',
      'label': 'Chauffage automatique',
      'desc': 'Active si la température passe sous le seuil min.',
      'icon': Icons.local_fire_department_rounded,
      'color': AppColors.green,
    },
    {
      'key': 'autoLighting',
      'label': 'Éclairage automatique',
      'desc': 'Gère le cycle lumineux selon la durée configurée.',
      'icon': Icons.light_mode_rounded,
      'color': AppColors.yellow,
    },
    {
      'key': 'autoFeeding',
      'label': 'Alimentation automatique',
      'desc': 'Distribution quand le niveau nourriture est bas.',
      'icon': Icons.restaurant_rounded,
      'color': AppColors.green,
    },
    {
      'key': 'autoWatering',
      'label': 'Abreuvement automatique',
      'desc': "Remplit l'abreuvoir si niveau eau bas.",
      'icon': Icons.water_drop_outlined,
      'color': AppColors.blue,
    },
  ];

  bool _val(String key) {
    switch (key) {
      case 'autoVentilation':
        return cfg.autoVentilation;
      case 'autoHeating':
        return cfg.autoHeating;
      case 'autoLighting':
        return cfg.autoLighting;
      case 'autoFeeding':
        return cfg.autoFeeding;
      default:
        return cfg.autoWatering;
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepTitle(
          'Automatismes',
          'Active les équipements à piloter automatiquement.',
        ),
        const SizedBox(height: 18),
        ..._items.map((a) {
          final key = a['key'] as String;
          final val = _val(key);
          final color = a['color'] as Color;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: val
                    ? color.withOpacity(0.3)
                    : AppColors.dark.withOpacity(0.07),
                width: val ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: val
                        ? color.withOpacity(0.12)
                        : AppColors.dark.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    a['icon'] as IconData,
                    color: val ? color : AppColors.muted,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a['label'] as String,
                        style: TextStyle(
                          color: val ? AppColors.dark : AppColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a['desc'] as String,
                        style: TextStyle(
                          color: AppColors.muted.withOpacity(0.8),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => onFieldChange(key, !val),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 46,
                    height: 26,
                    decoration: BoxDecoration(
                      color: val
                          ? AppColors.green
                          : AppColors.muted.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      alignment: val
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 28),
        Row(
          children: [
            WizardBackButton(onTap: onBack),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: onLaunch,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.cream,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'LANCER LE SYSTÈME',
                        style: TextStyle(
                          color: AppColors.cream,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
