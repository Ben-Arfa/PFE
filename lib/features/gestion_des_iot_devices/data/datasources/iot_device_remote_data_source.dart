import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/index.dart';

class IotDeviceRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  IotDeviceRemoteDataSource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';
  bool get _isAuthenticated => _userId.isNotEmpty;

  CollectionReference<Map<String, dynamic>> _devicesCollection() {
    if (!_isAuthenticated) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('iot_devices');
  }

  // CRUD Operations
  Future<String> createDevice(IotDevice device) async {
    final docRef = await _devicesCollection().add(device.toMap());
    return docRef.id;
  }

  Future<void> updateDevice(IotDevice device) async {
    await _devicesCollection().doc(device.id).update(device.toMap());
  }

  Future<void> deleteDevice(String deviceId) async {
    await _devicesCollection().doc(deviceId).delete();
    // Supprimer aussi les lectures associées
    final readings = await _devicesCollection()
        .doc(deviceId)
        .collection('readings')
        .get();
    for (final doc in readings.docs) {
      await doc.reference.delete();
    }
  }

  Future<IotDevice?> getDevice(String deviceId) async {
    try {
      final doc = await _devicesCollection().doc(deviceId).get();
      if (!doc.exists) return null;
      return IotDevice.fromMap(doc.data() ?? {}, doc.id);
    } catch (e) {
      rethrow;
    }
  }

  // Stream operations
  Stream<List<IotDevice>> watchAllDevices() {
    return _devicesCollection().snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => IotDevice.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Stream<List<IotDevice>> watchBuildingDevices(String buildingId) {
    return _devicesCollection()
        .where('buildingId', isEqualTo: buildingId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => IotDevice.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<IotDevice?> watchDevice(String deviceId) {
    return _devicesCollection().doc(deviceId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return IotDevice.fromMap(doc.data() ?? {}, doc.id);
    });
  }

  // Sensor readings
  Stream<List<SensorReading>> watchDeviceReadings(
    String deviceId, {
    int limit = 100,
  }) {
    return _devicesCollection()
        .doc(deviceId)
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SensorReading.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> recordReading(SensorReading reading) async {
    await _devicesCollection()
        .doc(reading.deviceId)
        .collection('readings')
        .add(reading.toMap());

    // Mettre à jour lastSync du device
    await _devicesCollection().doc(reading.deviceId).update({
      'lastSync': Timestamp.now(),
    });
  }

  Future<void> clearOldReadings(
    String deviceId, {
    required Duration olderThan,
  }) async {
    final cutoffTime = DateTime.now().subtract(olderThan);
    final query = await _devicesCollection()
        .doc(deviceId)
        .collection('readings')
        .where('timestamp', isLessThan: Timestamp.fromDate(cutoffTime))
        .get();

    for (final doc in query.docs) {
      await doc.reference.delete();
    }
  }
}
