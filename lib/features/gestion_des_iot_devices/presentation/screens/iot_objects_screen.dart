import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/iot_device_provider.dart';
import '../screens/device_details_screen.dart';
import '../widgets/add_device_dialog.dart';
import '../widgets/device_cards.dart';

class IotObjectsScreen extends ConsumerWidget {
  const IotObjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesStream = ref.watch(iotDevicesStreamProvider);

    return Scaffold(
      body: devicesStream.when(
        loading: () => const LoadingDevicesPlaceholder(),
        error: (err, stack) => ErrorPlaceholder(message: err.toString()),
        data: (devices) {
          if (devices.isEmpty) {
            return const EmptyDevicesPlaceholder();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return DeviceCard(
                device: device,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DeviceDetailsScreen(deviceId: device.id),
                    ),
                  );
                },
                onDelete: () =>
                    _showDeleteConfirmation(context, ref, device.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddDeviceDialog());
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String deviceId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'appareil?'),
        content: const Text(
          'Cette action supprimera l\'appareil et toutes ses lectures. '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(deleteIotDeviceProvider.notifier)
                    .deleteDevice(deviceId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appareil supprimé avec succès'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
