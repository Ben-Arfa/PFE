import '../entities/index.dart';

abstract class IotDeviceRepository {
  // CRUD operations
  Future<String> createDevice(IotDevice device);
  Future<void> updateDevice(IotDevice device);
  Future<void> deleteDevice(String deviceId);
  Future<IotDevice?> getDevice(String deviceId);

  // Stream operations
  Stream<List<IotDevice>> watchAllDevices();
  Stream<List<IotDevice>> watchBuildingDevices(String buildingId);
  Stream<IotDevice?> watchDevice(String deviceId);

  // Sensor readings
  Stream<List<SensorReading>> watchDeviceReadings(
    String deviceId, {
    int limit = 100,
  });
  Future<void> recordReading(SensorReading reading);
  Future<void> clearOldReadings(String deviceId, {required Duration olderThan});
}
