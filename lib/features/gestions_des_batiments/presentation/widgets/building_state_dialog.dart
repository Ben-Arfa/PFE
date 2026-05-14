import 'package:flutter/material.dart';
import 'package:kiwo/features/gestions_des_batiments/data/services/building_service.dart';
import 'package:kiwo/features/gestions_des_batiments/domain/entities/building.dart';

class BuildingStateDialog extends StatefulWidget {
  final Building building;

  const BuildingStateDialog({required this.building, super.key});

  @override
  State<BuildingStateDialog> createState() => _BuildingStateDialogState();
}

class _BuildingStateDialogState extends State<BuildingStateDialog> {
  final BuildingService _service = BuildingService();
  bool _loading = true;
  double? _temperature;
  double? _humidity;
  bool _ventilation = false;
  bool _heating = false;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final sensors = await _service.getLatestSensorsForBuilding(
        widget.building.id,
      );
      final controls = await _service.getBuildingControls(widget.building.id);
      setState(() {
        _temperature = sensors['temperature'];
        _humidity = sensors['humidity'];
        _ventilation = controls['ventilationOn'] == true;
        _heating = controls['heatingOn'] == true;
      });
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleVentilation(bool value) async {
    setState(() => _loading = true);
    try {
      await _service.setVentilation(widget.building.id, value);
      setState(() => _ventilation = value);
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleHeating(bool value) async {
    setState(() => _loading = true);
    try {
      await _service.setHeating(widget.building.id, value);
      setState(() => _heating = value);
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'État - ${widget.building.name}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Température actuelle',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _temperature != null
                          ? '${_temperature!.toStringAsFixed(1)} °C'
                          : 'N/A',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Humidité actuelle',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _humidity != null
                          ? '${_humidity!.toStringAsFixed(0)} %'
                          : 'N/A',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Ventilation'),
                      value: _ventilation,
                      onChanged: (v) => _toggleVentilation(v),
                    ),
                    SwitchListTile(
                      title: const Text('Chauffage'),
                      value: _heating,
                      onChanged: (v) => _toggleHeating(v),
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
