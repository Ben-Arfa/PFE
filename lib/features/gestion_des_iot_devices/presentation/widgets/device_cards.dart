import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/index.dart';

class DeviceCard extends StatelessWidget {
  final IotDevice device;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEditThresholds;

  const DeviceCard({
    required this.device,
    required this.onTap,
    this.onDelete,
    this.onEditThresholds,
    super.key,
  });

  String _formatDate(DateTime date) {
    return date.toString().split('.')[0].substring(0, 16);
  }

  @override
  Widget build(BuildContext context) {
    final lastSyncText = device.lastSync != null
        ? _formatDate(device.lastSync!)
        : 'Jamais synchronisé';

    final tempMin = _numberFromMetadata('tempMin');
    final tempMax = _numberFromMetadata('tempMax');
    final humidityMin = _numberFromMetadata('humidityMin');
    final humidityMax = _numberFromMetadata('humidityMax');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: device.isActive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sensors_rounded,
                      color: device.isActive ? Colors.green : Colors.red,
                      size: 24,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          device.type,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onEditThresholds != null)
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      tooltip: 'Modifier les seuils',
                      color: Colors.blue,
                      onPressed: onEditThresholds,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_rounded, size: 20),
                      tooltip: 'Supprimer',
                      color: Colors.red,
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid == null) {
                          return Text(
                            'Bâtiment: ${device.buildingId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        }

                        return StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>
                        >(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .collection('buildings')
                              .doc(device.buildingId)
                              .snapshots(),
                          builder: (context, snap) {
                            final name = (snap.hasData && snap.data!.exists)
                                ? (snap.data!.data()?['name'] ??
                                      device.buildingId)
                                : device.buildingId;
                            return Text(
                              'Bâtiment: $name',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.sync_rounded, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Dernière synchro: $lastSyncText',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.thermostat_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Seuils: ${tempMin.toStringAsFixed(0)}-${tempMax.toStringAsFixed(0)}°C | '
                      '${humidityMin.toStringAsFixed(0)}-${humidityMax.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: device.isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  device.isActive ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: device.isActive
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _numberFromMetadata(String key) {
    final value = device.metadata[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? _defaultFor(key);
    return _defaultFor(key);
  }

  double _defaultFor(String key) {
    switch (key) {
      case 'tempMin':
        return 18;
      case 'tempMax':
        return 30;
      case 'humidityMin':
        return 40;
      case 'humidityMax':
        return 80;
      default:
        return 0;
    }
  }
}

class SensorReadingCard extends StatelessWidget {
  final SensorReading reading;

  const SensorReadingCard({required this.reading, super.key});

  @override
  Widget build(BuildContext context) {
    final local = reading.timestamp.toLocal();
    final timeFormat =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}:${local.second.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeFormat,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SensorMetric(
                  icon: Icons.thermostat_rounded,
                  label: 'Temp.',
                  value: '${reading.temperature.toStringAsFixed(1)}°C',
                  color: Colors.red,
                ),
                _SensorMetric(
                  icon: Icons.water_drop_rounded,
                  label: 'Humidité',
                  value: '${reading.humidity.toStringAsFixed(0)}%',
                  color: Colors.blue,
                ),
                if (reading.co2 != null)
                  _SensorMetric(
                    icon: Icons.air_rounded,
                    label: 'CO₂',
                    value: '${reading.co2!.toStringAsFixed(0)} ppm',
                    color: Colors.grey,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SensorMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}

class EmptyDevicesPlaceholder extends StatelessWidget {
  const EmptyDevicesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucun appareil IoT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur + pour ajouter un appareil',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class LoadingDevicesPlaceholder extends StatelessWidget {
  const LoadingDevicesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorPlaceholder extends StatelessWidget {
  final String message;

  const ErrorPlaceholder({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_rounded, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Erreur',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
