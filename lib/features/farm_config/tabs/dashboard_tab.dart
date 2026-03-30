// lib/features/farm_config/tabs/dashboard_tab.dart
//
// Tableau de bord principal.
// Affiche les données capteurs configurées.
// Sous-onglets : CAPTEURS / ÉQUIPEMENTS / MON ÉLEVAGE

import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/models.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/sensor_history_chart.dart';

class DashboardTab extends StatefulWidget {
  final SystemConfig cfg;
  final SystemState sysState;
  final Map<String, bool> equipState;
  final bool Function(String id, double value) sensorOk;
  final VoidCallback onLaunch;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final void Function(String key, bool value) onEquipToggle;
  final VoidCallback onGoToConfig;

  const DashboardTab({
    required this.cfg,
    required this.sysState,
    required this.equipState,
    required this.sensorOk,
    required this.onLaunch,
    required this.onPause,
    required this.onStop,
    required this.onEquipToggle,
    required this.onGoToConfig,
    super.key,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab>
    with SingleTickerProviderStateMixin {
  late TabController _innerTab;

  Map<String, SensorState> _sensorStates = {};

  Map<String, SensorState> _buildSensorStates() => {
    'temp': SensorState(
      id: 'temp',
      label: 'TEMPÉRATURE',
      unit: '°C',
      value: (widget.cfg.tempMin + widget.cfg.tempMax) / 2,
      min: 0.0,
      max: 50.0,
      connected: true,
      history: const [],
    ),
    'hum': SensorState(
      id: 'hum',
      label: 'HUMIDITÉ',
      unit: '%',
      value: (widget.cfg.humMin + widget.cfg.humMax) / 2,
      min: 0.0,
      max: 100.0,
      connected: true,
      history: const [],
    ),
    'water': SensorState(
      id: 'water',
      label: "NIV. D'EAU",
      unit: '%',
      value: 70.0,
      min: 0.0,
      max: 100.0,
      connected: true,
      history: const [],
    ),
    'food': SensorState(
      id: 'food',
      label: 'NOURRITURE',
      unit: '%',
      value: 60.0,
      min: 0.0,
      max: 100.0,
      connected: true,
      history: const [],
    ),
    'co2': SensorState(
      id: 'co2',
      label: 'CO₂',
      unit: 'ppm',
      value: widget.cfg.co2Max * 0.6,
      min: 0.0,
      max: 5000.0,
      connected: true,
      history: const [],
    ),
    'ammo': SensorState(
      id: 'ammo',
      label: 'AMMONIAC',
      unit: 'ppm',
      value: widget.cfg.ammoniacMax * 0.5,
      min: 0.0,
      max: 50.0,
      connected: true,
      history: const [],
    ),
  };

  @override
  void initState() {
    super.initState();
    _innerTab = TabController(length: 3, vsync: this);
    _sensorStates = _buildSensorStates();
  }

  @override
  void didUpdateWidget(DashboardTab old) {
    super.didUpdateWidget(old);
    if (old.cfg != widget.cfg || old.sysState != widget.sysState) {
      setState(() => _sensorStates = _buildSensorStates());
    }
  }

  @override
  void dispose() {
    _innerTab.dispose();
    super.dispose();
  }

  // ── Seuils pour vérifier si une valeur est OK ──────────────────

  bool _isOk(String id, double value) => widget.sensorOk(id, value);

  List<SensorState> get _alertSensors => _sensorStates.values
      .where((s) => s.connected && !_isOk(s.id, s.value))
      .toList();

  @override
  Widget build(BuildContext context) {
    if (!widget.cfg.isConfigured) {
      return _EmptyDashboard(onGoToConfig: widget.onGoToConfig);
    }

    return Column(
      children: [
        // ── En-tête fixe : carte statut + alertes ────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              _SystemStatusCard(
                cfg: widget.cfg,
                sysState: widget.sysState,
                equipState: widget.equipState,
                onLaunch: widget.onLaunch,
                onPause: widget.onPause,
                onStop: widget.onStop,
              ),
              if (_alertSensors.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._alertSensors.map((s) => _AlertBanner(sensor: s)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),

        // ── Sous-onglets ──────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TabBar(
            controller: _innerTab,
            labelColor: AppColors.dark,
            unselectedLabelColor: AppColors.muted,
            labelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
            indicatorColor: AppColors.green,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'CAPTEURS'),
              Tab(text: 'ÉQUIPEMENTS'),
              Tab(text: 'MON ÉLEVAGE'),
            ],
          ),
        ),

        // ── Contenu ───────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _innerTab,
            children: [
              _SensorsView(
                states: _sensorStates,
                isOk: _isOk,
                cfg: widget.cfg,
                sysState: widget.sysState,
                onToggleSensor: (_) {},
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: _EquipmentPanel(
                  sysState: widget.sysState,
                  equipState: widget.equipState,
                  onToggle: widget.onEquipToggle,
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: FarmSummaryCard(cfg: widget.cfg),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Vue capteurs (grille + détail au tap)
// ─────────────────────────────────────────────────────────────────

class _SensorsView extends StatefulWidget {
  final Map<String, SensorState> states;
  final bool Function(String id, double value) isOk;
  final SystemConfig cfg;
  final SystemState sysState;
  final void Function(String id) onToggleSensor;

  const _SensorsView({
    required this.states,
    required this.isOk,
    required this.cfg,
    required this.sysState,
    required this.onToggleSensor,
  });

  @override
  State<_SensorsView> createState() => _SensorsViewState();
}

class _SensorsViewState extends State<_SensorsView> {
  String? _selected; // id du capteur dont on affiche le détail
  final ScrollController _scrollCtrl = ScrollController();
  final GlobalKey _detailKey = GlobalKey();

  static const _sensorMeta = {
    'temp': {'icon': Icons.thermostat_rounded, 'color': Color(0xFF4B7B28)},
    'hum': {'icon': Icons.water_drop_rounded, 'color': Color(0xFFA1B4C8)},
    'water': {'icon': Icons.opacity_rounded, 'color': Color(0xFF4B7B28)},
    'food': {'icon': Icons.restaurant_rounded, 'color': Color(0xFFAB1717)},
    'co2': {'icon': Icons.air_rounded, 'color': Color(0xFF7A7060)},
    'ammo': {'icon': Icons.science_rounded, 'color': Color(0xFF4B7B28)},
  };

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onSensorTap(String sensorId) {
    final nextSelected = _selected == sensorId ? null : sensorId;
    setState(() => _selected = nextSelected);

    if (nextSelected == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _detailKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: 0.08,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sensorList = widget.states.values.toList();

    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          // Grille des cartes capteurs
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.6,
            ),
            itemCount: sensorList.length,
            itemBuilder: (_, i) {
              final s = sensorList[i];
              final meta = _sensorMeta[s.id]!;
              final ok = s.connected && widget.isOk(s.id, s.value);
              return _SensorCard(
                state: s,
                icon: meta['icon'] as IconData,
                color: meta['color'] as Color,
                isOk: ok,
                isSelected: _selected == s.id,
                onTap: () => _onSensorTap(s.id),
                onToggle: () => widget.onToggleSensor(s.id),
              );
            },
          ),

          // Panneau détail / historique du capteur sélectionné
          if (_selected != null && widget.states.containsKey(_selected)) ...[
            const SizedBox(height: 16),
            Container(
              key: _detailKey,
              child: _SensorDetailPanel(
                state: widget.states[_selected!]!,
                icon: _sensorMeta[_selected!]!['icon'] as IconData,
                color: _sensorMeta[_selected!]!['color'] as Color,
                isOk: widget.isOk(_selected!, widget.states[_selected!]!.value),
                cfg: widget.cfg,
                onToggle: () => widget.onToggleSensor(_selected!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte capteur individuelle
// ─────────────────────────────────────────────────────────────────

class _SensorCard extends StatelessWidget {
  final SensorState state;
  final IconData icon;
  final Color color;
  final bool isOk;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _SensorCard({
    required this.state,
    required this.icon,
    required this.color,
    required this.isOk,
    required this.isSelected,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final disconnected = !state.connected;
    final displayColor = disconnected
        ? AppColors.muted
        : (isOk ? color : AppColors.beetRed);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.green
                : (!isOk && !disconnected)
                ? AppColors.beetRed.withOpacity(0.5)
                : disconnected
                ? AppColors.muted.withOpacity(0.3)
                : Colors.transparent,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: displayColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(icon, color: displayColor, size: 11),
                ),
                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: disconnected
                        ? AppColors.muted.withOpacity(0.15)
                        : (isOk ? AppColors.green : AppColors.beetRed)
                              .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    disconnected ? 'OFF' : (isOk ? 'Normal' : 'Alerte'),
                    style: TextStyle(
                      color: disconnected
                          ? AppColors.muted
                          : (isOk ? AppColors.green : AppColors.beetRed),
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      disconnected
                          ? '--'
                          : state.value.toStringAsFixed(
                              state.unit == 'ppm' ? 0 : 1,
                            ),
                      style: TextStyle(
                        color: disconnected ? AppColors.muted : AppColors.dark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (!disconnected)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2, left: 2),
                        child: Text(
                          state.unit,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: disconnected
                        ? 0
                        : ((state.value - state.min) / (state.max - state.min))
                              .clamp(0.0, 1.0),
                    minHeight: 2,
                    backgroundColor: Color(0xFFE8E2D4),
                    valueColor: AlwaysStoppedAnimation(displayColor),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  state.label,
                  style: TextStyle(
                    color: AppColors.cream.withOpacity(0.3),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Panneau détail d'un capteur (historique + infos)
// ─────────────────────────────────────────────────────────────────

class _SensorDetailPanel extends StatelessWidget {
  final SensorState state;
  final IconData icon;
  final Color color;
  final bool isOk;
  final SystemConfig cfg;
  final VoidCallback onToggle;

  const _SensorDetailPanel({
    required this.state,
    required this.icon,
    required this.color,
    required this.isOk,
    required this.cfg,
    required this.onToggle,
  });

  // Seuils selon le type de capteur
  double? get _alertMax {
    switch (state.id) {
      case 'temp':
        return cfg.tempMax;
      case 'hum':
        return cfg.humMax;
      case 'co2':
        return cfg.co2Max;
      case 'ammo':
        return cfg.ammoniacMax;
      default:
        return null;
    }
  }

  String get _thresholdLabel {
    switch (state.id) {
      case 'temp':
        return 'Cible : ${cfg.tempMin.toStringAsFixed(0)}–${cfg.tempMax.toStringAsFixed(0)} °C';
      case 'hum':
        return 'Cible : ${cfg.humMin.toStringAsFixed(0)}–${cfg.humMax.toStringAsFixed(0)} %';
      case 'water':
        return 'Alerte si < ${cfg.waterAlertPct.toStringAsFixed(0)} %';
      case 'food':
        return 'Alerte si < ${cfg.foodAlertPct.toStringAsFixed(0)} %';
      case 'co2':
        return 'Max : ${cfg.co2Max.toStringAsFixed(0)} ppm';
      case 'ammo':
        return 'Max : ${cfg.ammoniacMax.toStringAsFixed(0)} ppm';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final disconnected = !state.connected;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dark.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.label,
                      style: const TextStyle(
                        color: AppColors.dark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _thresholdLabel,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              // Toggle connexion capteur
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: disconnected
                        ? AppColors.muted.withOpacity(0.1)
                        : Color(0xFFEEF4E8),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: disconnected
                          ? AppColors.muted.withOpacity(0.3)
                          : AppColors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        disconnected
                            ? Icons.wifi_off_rounded
                            : Icons.wifi_rounded,
                        size: 12,
                        color: disconnected ? AppColors.muted : AppColors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        disconnected ? 'Déconnecté' : 'Connecté',
                        style: TextStyle(
                          color: disconnected
                              ? AppColors.muted
                              : AppColors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Valeur courante
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                disconnected
                    ? '--'
                    : state.value.toStringAsFixed(state.unit == 'ppm' ? 0 : 1),
                style: TextStyle(
                  color: disconnected
                      ? AppColors.muted
                      : (isOk ? AppColors.dark : AppColors.beetRed),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(
                  state.unit,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // Min / Max sur l'historique
              if (state.history.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MiniStat(
                      'MAX',
                      state.history
                          .map((r) => r.value)
                          .reduce((a, b) => a > b ? a : b),
                      state.unit,
                      AppColors.beetRed,
                    ),
                    const SizedBox(height: 2),
                    _MiniStat(
                      'MIN',
                      state.history
                          .map((r) => r.value)
                          .reduce((a, b) => a < b ? a : b),
                      state.unit,
                      AppColors.green,
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Graphique historique
          SensorHistoryChart(
            state: state,
            color: disconnected
                ? AppColors.muted
                : (isOk ? color : AppColors.beetRed),
            alertMax: _alertMax,
            height: 70,
          ),

          const SizedBox(height: 8),

          // Légende axe temps
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '−60s',
                style: TextStyle(
                  color: AppColors.muted.withOpacity(0.5),
                  fontSize: 9,
                ),
              ),
              Text(
                'Maintenant',
                style: TextStyle(
                  color: AppColors.muted.withOpacity(0.5),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  const _MiniStat(this.label, this.value, this.unit, this.color);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '$label ',
        style: TextStyle(
          color: AppColors.muted,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      Text(
        '${value.toStringAsFixed(unit == 'ppm' ? 0 : 1)} $unit',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────
// Bannière d'alerte
// ─────────────────────────────────────────────────────────────────

class _AlertBanner extends StatelessWidget {
  final SensorState sensor;
  const _AlertBanner({required this.sensor});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.beetRed.withOpacity(0.07),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.beetRed.withOpacity(0.25)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.beetRed,
          size: 15,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${sensor.label} hors seuil : ${sensor.value.toStringAsFixed(sensor.unit == 'ppm' ? 0 : 1)} ${sensor.unit}',
            style: const TextStyle(
              color: AppColors.beetRed,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// Dashboard vide
// ─────────────────────────────────────────────────────────────────

class _EmptyDashboard extends StatelessWidget {
  final VoidCallback onGoToConfig;
  const _EmptyDashboard({required this.onGoToConfig});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Color(0xFFF2F7EC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('🐔', style: TextStyle(fontSize: 38)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun élevage configuré',
            style: TextStyle(
              color: AppColors.dark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Configure ton type de volaille pour démarrer l'automatisation.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onGoToConfig,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CONFIGURER MON ÉLEVAGE',
                    style: TextStyle(
                      color: AppColors.cream,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFEEF4E8),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// Carte statut système
// ─────────────────────────────────────────────────────────────────

class _SystemStatusCard extends StatelessWidget {
  final SystemConfig cfg;
  final SystemState sysState;
  final Map<String, bool> equipState;
  final VoidCallback onLaunch, onPause, onStop;

  const _SystemStatusCard({
    required this.cfg,
    required this.sysState,
    required this.equipState,
    required this.onLaunch,
    required this.onPause,
    required this.onStop,
  });

  Color get _c => _r(
    AppColors.green,
    Color(0xFFEEF4E8),
    AppColors.beetRed,
    AppColors.muted,
  );
  String get _l => _r('SYSTÈME ACTIF', 'EN PAUSE', 'ALERTE', 'INACTIF');
  IconData get _i => _r(
    Icons.play_circle_fill_rounded,
    Icons.pause_circle_filled_rounded,
    Icons.error_rounded,
    Icons.radio_button_unchecked_rounded,
  );
  T _r<T>(T run, T pause, T alert, T idle) {
    switch (sysState) {
      case SystemState.running:
        return run;
      case SystemState.paused:
        return pause;
      case SystemState.alert:
        return alert;
      default:
        return idle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIdle = sysState == SystemState.idle;
    final isPaused = sysState == SystemState.paused;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFFE8E2D4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _c.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_i, color: _c, size: 10),
                          const SizedBox(width: 5),
                          Text(
                            _l,
                            style: TextStyle(
                              color: _c,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cfg.farmName.isNotEmpty
                                  ? cfg.farmName
                                  : cfg.poultryType,
                              style: const TextStyle(
                                color: AppColors.dark,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${cfg.birdCount} sujets · ${cfg.surfaceM2.toStringAsFixed(0)} m²',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (isIdle)
                    _Btn(
                      'LANCER',
                      AppColors.green,
                      Icons.play_arrow_rounded,
                      onLaunch,
                    ),
                  if (!isIdle) ...[
                    _Btn(
                      isPaused ? 'REPRENDRE' : 'PAUSE',
                      isPaused ? AppColors.yellow : AppColors.green,
                      isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      onPause,
                    ),
                    const SizedBox(height: 8),
                    _Btn(
                      'ARRÊTER',
                      AppColors.beetRed,
                      Icons.stop_rounded,
                      onStop,
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (!isIdle) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withOpacity(0.07)),
            const SizedBox(height: 12),
            Row(
              children: [
                _Pill(
                  'Ventil.',
                  equipState['ventilation']! ? 'ON' : 'OFF',
                  equipState['ventilation']!
                      ? AppColors.green
                      : AppColors.muted,
                ),
                const SizedBox(width: 6),
                _Pill(
                  'Chauff.',
                  equipState['heating']! ? 'ON' : 'OFF',
                  equipState['heating']! ? AppColors.green : AppColors.muted,
                ),
                const SizedBox(width: 6),
                _Pill(
                  'Lumière',
                  equipState['lighting']! ? 'ON' : 'OFF',
                  equipState['lighting']! ? AppColors.yellow : AppColors.muted,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String l;
  final Color c;
  final IconData i;
  final VoidCallback t;
  const _Btn(this.l, this.c, this.i, this.t);

  Color get _fg => ThemeData.estimateBrightnessForColor(c) == Brightness.dark
      ? AppColors.cream
      : AppColors.dark;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: t,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i, color: _fg, size: 13),
          const SizedBox(width: 5),
          Text(
            l,
            style: TextStyle(
              color: _fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  final String l, v;
  final Color c;
  const _Pill(this.l, this.v, this.c);

  bool get _isOn => v == 'ON';

  Color get _bg =>
      _isOn ? c.withOpacity(0.18) : AppColors.dark.withOpacity(0.06);

  Color get _border =>
      _isOn ? c.withOpacity(0.45) : AppColors.dark.withOpacity(0.15);

  Color get _labelColor => AppColors.dark.withOpacity(0.75);

  Color get _valueColor => _isOn ? AppColors.dark : AppColors.muted;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _bg,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: _border),
    ),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 10),
        children: [
          TextSpan(
            text: '$l ',
            style: TextStyle(color: _labelColor, fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: v,
            style: TextStyle(color: _valueColor, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// Panneau équipements
// ─────────────────────────────────────────────────────────────────

class _EquipmentPanel extends StatelessWidget {
  final SystemState sysState;
  final Map<String, bool> equipState;
  final void Function(String, bool) onToggle;
  const _EquipmentPanel({
    required this.sysState,
    required this.equipState,
    required this.onToggle,
  });

  static const _items = [
    {
      'key': 'ventilation',
      'label': 'Ventilation',
      'icon': Icons.air_outlined,
      'color': AppColors.blue,
    },
    {
      'key': 'heating',
      'label': 'Chauffage',
      'icon': Icons.local_fire_department_rounded,
      'color': AppColors.green,
    },
    {
      'key': 'lighting',
      'label': 'Éclairage',
      'icon': Icons.light_mode_rounded,
      'color': Color(0xFFEEF4E8),
    },
    {
      'key': 'feeding',
      'label': 'Alimentation',
      'icon': Icons.restaurant_rounded,
      'color': AppColors.green,
    },
    {
      'key': 'watering',
      'label': 'Abreuvement',
      'icon': Icons.water_drop_outlined,
      'color': AppColors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) => Column(
    children: _items.map((e) {
      final key = e['key'] as String;
      final isOn = equipState[key] ?? false;
      final color = e['color'] as Color;
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
              e['icon'] as IconData,
              color: isOn ? color : AppColors.muted,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e['label'] as String,
                    style: TextStyle(
                      color: isOn ? AppColors.dark : AppColors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    sysState == SystemState.idle
                        ? 'Système inactif'
                        : isOn
                        ? 'En fonctionnement'
                        : 'Arrêté',
                    style: TextStyle(
                      color: isOn
                          ? AppColors.green.withOpacity(0.7)
                          : AppColors.muted.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: sysState == SystemState.idle
                  ? null
                  : () => onToggle(key, !isOn),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 46,
                height: 26,
                decoration: BoxDecoration(
                  color: isOn
                      ? AppColors.green
                      : AppColors.muted.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  alignment: isOn
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
    }).toList(),
  );
}

// ─────────────────────────────────────────────────────────────────
// Carte résumé élevage
// ─────────────────────────────────────────────────────────────────

class FarmSummaryCard extends StatelessWidget {
  final SystemConfig cfg;
  const FarmSummaryCard({required this.cfg, super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.dark.withOpacity(0.07)),
    ),
    child: Column(
      children: [
        InfoRow(
          Icons.thermostat_rounded,
          'Temp. cible',
          '${cfg.tempMin.toStringAsFixed(0)}–${cfg.tempMax.toStringAsFixed(0)} °C',
          AppColors.green,
        ),
        const KiwoDivider(),
        InfoRow(
          Icons.water_drop_rounded,
          'Humidité cible',
          '${cfg.humMin.toStringAsFixed(0)}–${cfg.humMax.toStringAsFixed(0)} %',
          AppColors.blue,
        ),
        const KiwoDivider(),
        InfoRow(
          Icons.wb_sunny_rounded,
          'Éclairage/jour',
          '${cfg.lightHours.toStringAsFixed(0)} h',
          Color(0xFFEEF4E8),
        ),
        const KiwoDivider(),
        InfoRow(
          Icons.groups_rounded,
          'Effectif',
          '${cfg.birdCount} sujets',
          AppColors.green,
        ),
        const KiwoDivider(),
        InfoRow(
          Icons.square_foot_rounded,
          'Superficie',
          '${cfg.surfaceM2.toStringAsFixed(0)} m²',
          AppColors.muted,
        ),
      ],
    ),
  );
}
