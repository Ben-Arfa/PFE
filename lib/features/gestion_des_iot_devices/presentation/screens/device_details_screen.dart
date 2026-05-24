import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/iot_device_provider.dart';
import '../widgets/device_cards.dart';
import '../../data/services/esp32_dht22_service.dart';

String _formatDateTime(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class DeviceDetailsScreen extends ConsumerStatefulWidget {
  final String deviceId;

  const DeviceDetailsScreen({required this.deviceId, super.key});

  @override
  ConsumerState<DeviceDetailsScreen> createState() =>
      _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends ConsumerState<DeviceDetailsScreen> {
  Esp32DataResponse? _esp32Data;
  Timer? _pollingTimer;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    // Démarrer le polling toutes les 5 secondes
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchEsp32Data();
    });
    _fetchEsp32Data(); // Première lecture immédiate
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchEsp32Data() async {
    final device = await ref.read(
      iotDeviceStreamProvider(widget.deviceId).future,
    );
    final esp32Url = device?.metadata['esp32Url'] as String?;
    if (esp32Url == null || esp32Url.trim().isEmpty) return;

    try {
      final data = await ref
          .read(esp32Dht22ServiceProvider)
          .fetchData(baseUrl: esp32Url);
      if (mounted) setState(() => _esp32Data = data);
    } catch (_) {}
  }

  Future<void> _sendSeuils(dynamic device) async {
    final esp32Url = device.metadata['esp32Url'] as String?;
    if (esp32Url == null) return;

    // Utilise les seuils déjà dénormalisés dans le device via Building
    try {
      await ref
          .read(sendSeuilsProvider.notifier)
          .sendSeuils(
            baseUrl: esp32Url,
            tempMin: device.metadata['tempMin']?.toDouble() ?? 18.0,
            tempMax: device.metadata['tempMax']?.toDouble() ?? 30.0,
            humidityMin: device.metadata['humidityMin']?.toDouble() ?? 40.0,
            humidityMax: device.metadata['humidityMax']?.toDouble() ?? 80.0,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Seuils envoyés à l\'ESP32'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleMode(String esp32Url, String currentMode) async {
    final newMode = currentMode == 'auto' ? 'manuel' : 'auto';
    try {
      await ref
          .read(setModeProvider.notifier)
          .setMode(baseUrl: esp32Url, mode: newMode);
      await _fetchEsp32Data();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔄 Mode ${newMode == 'auto' ? 'Automatique' : 'Manuel'} activé',
            ),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleLed(String esp32Url, int index, bool currentState) async {
    try {
      await ref
          .read(setLedProvider.notifier)
          .setLed(baseUrl: esp32Url, index: index, state: !currentState);
      await _fetchEsp32Data();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur LED: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceStream = ref.watch(iotDeviceStreamProvider(widget.deviceId));
    final readingsStream = ref.watch(
      iotDeviceReadingsStreamProvider((widget.deviceId, 20)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'appareil'),
        elevation: 0,
        actions: [
          // Bouton sync manuel
          IconButton(
            icon: _isPolling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _fetchEsp32Data,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: deviceStream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorPlaceholder(message: err.toString()),
        data: (device) {
          if (device == null) {
            return const ErrorPlaceholder(message: 'Appareil non trouvé');
          }

          final esp32Url = device.metadata['esp32Url'] as String?;
          final hasEsp32 = esp32Url != null && esp32Url.trim().isNotEmpty;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── En-tête device ──────────────────────────────────────
                _DeviceHeader(device: device),

                // ── Panneau ESP32 temps réel ────────────────────────────
                if (hasEsp32) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Environnement en temps réel',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Carte température / humidité
                  _SensorLiveCard(data: _esp32Data),

                  const SizedBox(height: 12),

                  // Alertes actives
                  if (_esp32Data != null && _esp32Data!.hasAlerts)
                    _AlertsBanner(alerts: _esp32Data!.alerts),

                  const SizedBox(height: 12),

                  // LEDs
                  _LedPanel(
                    data: _esp32Data,
                    esp32Url: esp32Url!,
                    onToggleLed: _toggleLed,
                  ),

                  const SizedBox(height: 12),

                  // Contrôles
                  _ControlPanel(
                    data: _esp32Data,
                    esp32Url: esp32Url,
                    onToggleMode: _toggleMode,
                    onSendSeuils: () => _sendSeuils(device),
                    onSync: () async {
                      try {
                        await ref
                            .read(syncEsp32ReadingProvider.notifier)
                            .syncDevice(device);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Lecture enregistrée'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                        }
                      }
                    },
                  ),
                ],

                const SizedBox(height: 20),

                // ── Historique des lectures ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Historique des lectures',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                readingsStream.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                  error: (err, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: ErrorPlaceholder(message: err.toString()),
                  ),
                  data: (readings) {
                    if (readings.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'Aucune lecture disponible',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: readings.length,
                      itemBuilder: (_, i) =>
                          SensorReadingCard(reading: readings[i]),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// WIDGETS
// ════════════════════════════════════════════════════════════

class _DeviceHeader extends StatelessWidget {
  final dynamic device;
  const _DeviceHeader({required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: device.isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.sensors_rounded,
                  color: device.isActive ? Colors.green : Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      device.type,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: device.isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  device.isActive ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: device.isActive
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          if (device.lastSync != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.sync_rounded, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  'Dernière synchro : ${_formatDateTime(device.lastSync!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Carte température / humidité ─────────────────────────────
class _SensorLiveCard extends StatelessWidget {
  final Esp32DataResponse? data;
  const _SensorLiveCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: data == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _LiveMetric(
                      icon: Icons.thermostat_rounded,
                      label: 'Température',
                      value: '${data!.temperature.toStringAsFixed(1)}°C',
                      subtitle:
                          '${data!.tempMin.toStringAsFixed(0)}° - ${data!.tempMax.toStringAsFixed(0)}°',
                      color: _tempColor(
                        data!.temperature,
                        data!.tempMin,
                        data!.tempMax,
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.grey.shade200,
                    ),
                    _LiveMetric(
                      icon: Icons.water_drop_rounded,
                      label: 'Humidité',
                      value: '${data!.humidity.toStringAsFixed(0)}%',
                      subtitle:
                          '${data!.humidityMin.toStringAsFixed(0)}% - ${data!.humidityMax.toStringAsFixed(0)}%',
                      color: _humColor(
                        data!.humidity,
                        data!.humidityMin,
                        data!.humidityMax,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Color _tempColor(double temp, double min, double max) {
    if (temp < min) return Colors.blue;
    if (temp > max) return Colors.red;
    return Colors.green;
  }

  Color _humColor(double hum, double min, double max) {
    if (hum > max) return Colors.blue;
    if (hum < min) return Colors.orange;
    return Colors.green;
  }
}

class _LiveMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _LiveMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          'Seuils: $subtitle',
          style: TextStyle(fontSize: 10, color: Colors.grey[400]),
        ),
      ],
    );
  }
}

// ── Bannière alertes ─────────────────────────────────────────
class _AlertsBanner extends StatelessWidget {
  final List<String> alerts;
  const _AlertsBanner({required this.alerts});

  String _alertLabel(String alert) {
    switch (alert) {
      case 'temp_low':
        return '❄️ Température trop basse → Chauffage ON';
      case 'temp_high':
        return '🌡️ Température trop haute → Ventilation ON';
      case 'humidity_high':
        return '💧 Humidité trop haute → Déshumidification ON';
      case 'humidity_low':
        return '🏜️ Humidité trop basse';
      default:
        return alert;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ Alertes actives',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            ...alerts.map(
              (a) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _alertLabel(a),
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Panneau LEDs ─────────────────────────────────────────────
class _LedPanel extends StatelessWidget {
  final Esp32DataResponse? data;
  final String esp32Url;
  final Future<void> Function(String, int, bool) onToggleLed;

  const _LedPanel({
    required this.data,
    required this.esp32Url,
    required this.onToggleLed,
  });

  @override
  Widget build(BuildContext context) {
    final leds = data?.leds ?? [false, false, false, false];
    final isManuel = data?.mode == 'manuel';

    final ledConfig = [
      {
        'label': 'Chauffage',
        'color': Colors.red,
        'icon': Icons.local_fire_department_rounded,
      },
      {
        'label': 'Ventilation',
        'color': Colors.amber,
        'icon': Icons.air_rounded,
      },
      {
        'label': 'Déshumidification',
        'color': Colors.blue,
        'icon': Icons.water_drop_rounded,
      },
      {
        'label': 'Système OK',
        'color': Colors.green,
        'icon': Icons.check_circle_rounded,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'État des actionneurs',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Spacer(),
                  if (isManuel)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Override manuel',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (i) {
                  final config = ledConfig[i];
                  final isOn = i < leds.length ? leds[i] : false;
                  final color = config['color'] as Color;

                  return GestureDetector(
                    onTap: isManuel
                        ? () => onToggleLed(esp32Url, i, isOn)
                        : null,
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOn
                                ? color.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.1),
                            border: Border.all(
                              color: isOn ? color : Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: isOn
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Icon(
                            config['icon'] as IconData,
                            color: isOn ? color : Colors.grey.shade400,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          config['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: isOn ? color : Colors.grey[500],
                            fontWeight: isOn
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOn ? 'ON' : 'OFF',
                          style: TextStyle(
                            fontSize: 9,
                            color: isOn ? color : Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              if (isManuel) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Appuyez sur une LED pour la contrôler',
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Panneau de contrôle ──────────────────────────────────────
class _ControlPanel extends StatelessWidget {
  final Esp32DataResponse? data;
  final String esp32Url;
  final Future<void> Function(String, String) onToggleMode;
  final VoidCallback onSendSeuils;
  final VoidCallback onSync;

  const _ControlPanel({
    required this.data,
    required this.esp32Url,
    required this.onToggleMode,
    required this.onSendSeuils,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    final isAuto = data?.mode == 'auto';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contrôles',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Mode auto/manuel
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: data == null
                          ? null
                          : () => onToggleMode(esp32Url, data!.mode),
                      icon: Icon(
                        isAuto
                            ? Icons.auto_mode_rounded
                            : Icons.pan_tool_rounded,
                        size: 18,
                      ),
                      label: Text(
                        isAuto ? 'Mode Auto' : 'Mode Manuel',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isAuto ? Colors.green : Colors.orange,
                        side: BorderSide(
                          color: isAuto ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Envoyer seuils
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSendSeuils,
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text(
                        'Envoyer seuils',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sync lecture
                  IconButton(
                    onPressed: onSync,
                    icon: const Icon(Icons.save_rounded),
                    tooltip: 'Enregistrer lecture',
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
