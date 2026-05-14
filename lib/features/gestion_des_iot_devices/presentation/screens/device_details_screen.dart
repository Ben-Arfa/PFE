import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/iot_device_provider.dart';
import '../widgets/device_cards.dart';

String _formatDateTime(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class DeviceDetailsScreen extends ConsumerWidget {
  final String deviceId;

  const DeviceDetailsScreen({required this.deviceId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceStream = ref.watch(iotDeviceStreamProvider(deviceId));
    final readingsStream = ref.watch(
      iotDeviceReadingsStreamProvider((deviceId, 50)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Détails de l\'appareil'), elevation: 0),
      body: deviceStream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorPlaceholder(message: err.toString()),
        data: (device) {
          if (device == null) {
            return const ErrorPlaceholder(message: 'Appareil non trouvé');
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device info header
                Container(
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
                              color: device.isActive
                                  ? Colors.green
                                  : Colors.red,
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
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.fingerprint_rounded,
                        label: 'ID',
                        value: device.deviceId,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.home_work_rounded,
                        label: 'Bâtiment',
                        value: device.buildingId,
                      ),
                      if (device.lotId.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.inventory_2_rounded,
                          label: 'Lot',
                          value: device.lotId,
                        ),
                      ],
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.access_time_rounded,
                        label: 'Créé',
                        value: _formatDateTime(device.createdAt),
                      ),
                      if (device.lastSync != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.sync_rounded,
                          label: 'Dernière synchro',
                          value: _formatDateTime(device.lastSync!),
                        ),
                      ],
                      const SizedBox(height: 12),
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
                          device.isActive
                              ? 'Appareil Actif'
                              : 'Appareil Inactif',
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
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Lectures récentes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Sensor readings
                readingsStream.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                  error: (err, stack) => Padding(
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
                      itemBuilder: (context, i) {
                        return SensorReadingCard(reading: readings[i]);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
