import '../../domain/entities/index.dart';
import '../../domain/repositories/iot_device_repository.dart';
import '../datasources/iot_device_remote_data_source.dart';

class IotDeviceRepositoryImpl implements IotDeviceRepository {
  final IotDeviceRemoteDataSource _remoteDataSource;

  IotDeviceRepositoryImpl(this._remoteDataSource);

  @override
  Future<String> createDevice(IotDevice device) async {
    return await _remoteDataSource.createDevice(device);
  }

  @override
  Future<void> updateDevice(IotDevice device) async {
    return await _remoteDataSource.updateDevice(device);
  }

  @override
  Future<void> deleteDevice(String deviceId) async {
    return await _remoteDataSource.deleteDevice(deviceId);
  }

  @override
  Future<IotDevice?> getDevice(String deviceId) async {
    return await _remoteDataSource.getDevice(deviceId);
  }

  @override
  Stream<List<IotDevice>> watchAllDevices() {
    return _remoteDataSource.watchAllDevices();
  }

  @override
  Stream<List<IotDevice>> watchBuildingDevices(String buildingId) {
    return _remoteDataSource.watchBuildingDevices(buildingId);
  }

  @override
  Stream<IotDevice?> watchDevice(String deviceId) {
    return _remoteDataSource.watchDevice(deviceId);
  }

  @override
  Stream<List<SensorReading>> watchDeviceReadings(
    String deviceId, {
    int limit = 100,
  }) {
    return _remoteDataSource.watchDeviceReadings(deviceId, limit: limit);
  }

  @override
  Future<void> recordReading(SensorReading reading) async {
    return await _remoteDataSource.recordReading(reading);
  }

  @override
  Future<void> clearOldReadings(
    String deviceId, {
    required Duration olderThan,
  }) async {
    return await _remoteDataSource.clearOldReadings(
      deviceId,
      olderThan: olderThan,
    );
  }
}
