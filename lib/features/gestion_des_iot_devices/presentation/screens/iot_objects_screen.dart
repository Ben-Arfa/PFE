import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/iot_device.dart';
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
                onEditThresholds: () =>
                    _showThresholdsDialog(context, ref, device),
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

  Future<void> _showThresholdsDialog(
    BuildContext context,
    WidgetRef ref,
    IotDevice device,
  ) async {
    final thresholds = await showDialog<_ThresholdValues>(
      context: context,
      builder: (_) => _ThresholdsDialog(device: device),
    );

    if (thresholds == null) return;

    final updatedMetadata = Map<String, dynamic>.from(device.metadata)
      ..['tempMin'] = thresholds.tempMin
      ..['tempMax'] = thresholds.tempMax
      ..['humidityMin'] = thresholds.humidityMin
      ..['humidityMax'] = thresholds.humidityMax;

    try {
      await ref
          .read(updateIotDeviceProvider.notifier)
          .updateDevice(device.copyWith(metadata: updatedMetadata));

      final esp32Url = device.metadata['esp32Url'] as String?;
      var sentToSensor = false;
      Object? sensorError;

      if (esp32Url != null && esp32Url.trim().isNotEmpty) {
        try {
          await ref
              .read(sendSeuilsProvider.notifier)
              .sendSeuils(
                baseUrl: esp32Url,
                tempMin: thresholds.tempMin,
                tempMax: thresholds.tempMax,
                humidityMin: thresholds.humidityMin,
                humidityMax: thresholds.humidityMax,
              );
          sentToSensor = true;
        } catch (e) {
          sensorError = e;
        }
      }

      if (context.mounted) {
        final message = sentToSensor
            ? 'Seuils enregistres et envoyes au capteur'
            : sensorError == null
            ? 'Seuils enregistres dans Firebase. Adresse ESP32 manquante.'
            : 'Seuils enregistres dans Firebase. Envoi ESP32 echoue: $sensorError';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: sentToSensor ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }
  }
}

class _ThresholdValues {
  final double tempMin;
  final double tempMax;
  final double humidityMin;
  final double humidityMax;

  const _ThresholdValues({
    required this.tempMin,
    required this.tempMax,
    required this.humidityMin,
    required this.humidityMax,
  });
}

class _ThresholdsDialog extends StatefulWidget {
  final IotDevice device;

  const _ThresholdsDialog({required this.device});

  @override
  State<_ThresholdsDialog> createState() => _ThresholdsDialogState();
}

class _ThresholdsDialogState extends State<_ThresholdsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tempMinController;
  late final TextEditingController _tempMaxController;
  late final TextEditingController _humidityMinController;
  late final TextEditingController _humidityMaxController;

  @override
  void initState() {
    super.initState();
    _tempMinController = TextEditingController(
      text: _threshold('tempMin').toStringAsFixed(0),
    );
    _tempMaxController = TextEditingController(
      text: _threshold('tempMax').toStringAsFixed(0),
    );
    _humidityMinController = TextEditingController(
      text: _threshold('humidityMin').toStringAsFixed(0),
    );
    _humidityMaxController = TextEditingController(
      text: _threshold('humidityMax').toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _tempMinController.dispose();
    _tempMaxController.dispose();
    _humidityMinController.dispose();
    _humidityMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier les seuils'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      controller: _tempMinController,
                      label: 'Temp. min',
                      suffix: 'Â°C',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(
                      controller: _tempMaxController,
                      label: 'Temp. max',
                      suffix: 'Â°C',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      controller: _humidityMinController,
                      label: 'Hum. min',
                      suffix: '%',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(
                      controller: _humidityMaxController,
                      label: 'Hum. max',
                      suffix: '%',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded, size: 18),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final number = double.tryParse((value ?? '').replaceAll(',', '.'));
        if (number == null) return 'Valeur invalide';
        return null;
      },
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final values = _ThresholdValues(
      tempMin: _parse(_tempMinController.text),
      tempMax: _parse(_tempMaxController.text),
      humidityMin: _parse(_humidityMinController.text),
      humidityMax: _parse(_humidityMaxController.text),
    );

    if (values.tempMin >= values.tempMax) {
      _showError('La tempÃ©rature min doit Ãªtre infÃ©rieure au max');
      return;
    }

    if (values.humidityMin >= values.humidityMax) {
      _showError('L\'humiditÃ© min doit Ãªtre infÃ©rieure au max');
      return;
    }

    Navigator.of(context).pop(values);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  double _parse(String value) => double.parse(value.replaceAll(',', '.'));

  double _threshold(String key) {
    final value = widget.device.metadata[key];
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
