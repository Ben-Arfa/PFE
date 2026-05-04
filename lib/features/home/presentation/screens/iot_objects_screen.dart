import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IotObjectsScreen extends StatelessWidget {
  const IotObjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iotService = IotService();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('devices').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sensors_outlined, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Aucun appareil',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text('Aucun appareil IoT enregistré.'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i];
              final dev = d.data() as Map<String, dynamic>;
              final deviceId = dev['deviceId'] as String? ?? d.id;
              final buildingId = dev['buildingId'] as String? ?? '';
              final name = dev['name'] as String? ?? deviceId;

              return ListTile(
                leading: const Icon(Icons.sensors_rounded),
                title: Text(name),
                subtitle: Text('Bâtiment: $buildingId'),
                trailing: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _openDeviceDetails(
                    context,
                    iotService,
                    deviceId,
                    buildingId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openDeviceDetails(
    BuildContext context,
    IotService iotService,
    String deviceId,
    String buildingId,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceDetailsScreen(
          iotService: iotService,
          deviceId: deviceId,
          buildingId: buildingId,
        ),
      ),
    );
  }
}

class DeviceDetailsScreen extends StatelessWidget {
  final IotService iotService;
  final String deviceId;
  final String buildingId;

  const DeviceDetailsScreen({
    required this.iotService,
    required this.deviceId,
    required this.buildingId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device: $deviceId'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bâtiment',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Text(buildingId, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<SensorReading>>(
              stream: iotService.watchReadingsForDevice(deviceId),
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Center(child: Text('Erreur'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final readings = snap.data!;
                if (readings.isEmpty) {
                  return const Center(child: Text('Aucune lecture'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: readings.length,
                  itemBuilder: (context, i) {
                    final r = readings[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.thermostat_outlined),
                        title: Text(
                          'T: ${r.temperature.toStringAsFixed(1)}°C — H: ${r.humidity.toStringAsFixed(0)}%',
                        ),
                        subtitle: Text('${r.timestamp.toLocal()}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SensorReading {
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  const SensorReading({
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  factory SensorReading.fromMap(Map<String, dynamic> map) {
    final ts = map['timestamp'];
    DateTime date;
    if (ts is Timestamp) {
      date = ts.toDate();
    } else if (ts is DateTime) {
      date = ts;
    } else {
      date = DateTime.now();
    }

    return SensorReading(
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0,
      humidity: (map['humidity'] as num?)?.toDouble() ?? 0,
      timestamp: date,
    );
  }
}

class IotService {
  final FirebaseFirestore _firestore;

  IotService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<SensorReading>> watchReadingsForDevice(String deviceId) {
    return _firestore
        .collection('devices')
        .doc(deviceId)
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SensorReading.fromMap(doc.data()))
              .toList(),
        );
  }
}
