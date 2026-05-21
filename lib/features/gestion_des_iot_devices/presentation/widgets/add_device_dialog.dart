import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiwo/features/gestions_des_batiments/data/services/building_service.dart';
import 'package:kiwo/features/gestions_des_batiments/domain/entities/building.dart';
import '../../domain/entities/iot_device.dart';
import '../providers/iot_device_provider.dart';

String _generateRandomId() {
  const chars = 'abcdef0123456789';
  final random = List.generate(12, (i) => chars[(i * 7) % chars.length]).join();
  return random;
}

class AddDeviceDialog extends ConsumerStatefulWidget {
  final String? initialBuildingId;
  final String? initialLotId;

  const AddDeviceDialog({this.initialBuildingId, this.initialLotId, super.key});

  @override
  ConsumerState<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends ConsumerState<AddDeviceDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _deviceIdController;
  late final TextEditingController _buildingIdController;
  late final TextEditingController _esp32UrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _deviceIdController = TextEditingController(text: _generateRandomId());
    _buildingIdController = TextEditingController(
      text: widget.initialBuildingId ?? '',
    );
    _esp32UrlController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deviceIdController.dispose();
    _buildingIdController.dispose();
    _esp32UrlController.dispose();
    super.dispose();
  }

  void _createDevice() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veuillez entrer un nom')));
      return;
    }

    if (_deviceIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un ID appareil')),
      );
      return;
    }

    if (_buildingIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un ID bâtiment')),
      );
      return;
    }

    final device = IotDevice(
      id: _generateRandomId(),
      deviceId: _deviceIdController.text,
      name: _nameController.text,
      type: 'dht22',
      buildingId: _buildingIdController.text,
      lotId: '',
      isActive: true,
      createdAt: DateTime.now(),
      metadata: {
        if (_esp32UrlController.text.trim().isNotEmpty)
          'esp32Url': _esp32UrlController.text.trim(),
        'sensor': 'DHT22',
        'protocol': 'http',
      },
    );

    try {
      await ref.read(createIotDeviceProvider.notifier).createDevice(device);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appareil créé avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ajouter un capteur IoT',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du capteur',
                  hintText: 'Ex: Capteur Bâtiment A',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.sensors_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _deviceIdController,
                decoration: InputDecoration(
                  labelText: 'ID du capteur',
                  hintText: 'Identifiant unique',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.fingerprint_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _esp32UrlController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'Adresse ESP32',
                  hintText: 'Ex: 192.168.1.45',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.wifi_rounded),
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<Building>>(
                stream: BuildingService().watchBuildings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Erreur chargement bâtiments');
                  }

                  final buildings = snapshot.data ?? const <Building>[];

                  return DropdownButtonFormField<String>(
                    value: _buildingIdController.text.isEmpty
                        ? null
                        : _buildingIdController.text,
                    decoration: InputDecoration(
                      labelText: 'Bâtiment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.home_work_rounded),
                    ),
                    items: buildings
                        .map(
                          (b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _buildingIdController.text = value ?? '';
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _createDevice,
                    child: const Text('Créer'),
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
