import 'package:flutter/material.dart';
import '../../domain/entities/sensor_data.dart';

class SensorDataGrid extends StatelessWidget {
  final List<SensorData> sensors;
  final Widget Function(SensorData) itemBuilder;

  const SensorDataGrid({
    super.key,
    required this.sensors,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (sensors.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Aucune donnée disponible',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: sensors.length,
      itemBuilder: (context, index) => itemBuilder(sensors[index]),
    );
  }
}
