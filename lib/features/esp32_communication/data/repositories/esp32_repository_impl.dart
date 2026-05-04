import '../../domain/entities/esp32_device.dart';
import '../../domain/entities/sensor_data.dart';
import '../../domain/repositories/esp32_repository.dart';
import '../models/esp32_device_model.dart';
import '../services/esp32_service.dart';

class Esp32RepositoryImpl implements Esp32Repository {
  final Esp32Service _service;

  Esp32RepositoryImpl(this._service);

  @override
  Future<bool> connectToDevice(String ipAddress, int port) async {
    return await _service.connectToDevice(ipAddress, port);
  }

  @override
  Future<void> disconnect() async {
    await _service.disconnect();
  }

  @override
  Future<bool> isConnected() async {
    return _service.isConnected;
  }

  @override
  Stream<SensorData> watchSensorData(String sensorId) {
    return _service.dataStream
        .where((data) => data['id'] == sensorId)
        .map((data) => SensorData.fromJson(data));
  }

  @override
  Future<List<SensorData>> fetchLatestSensorData() async {
    // Implement based on your ESP32 API
    return [];
  }

  @override
  Future<void> sendCommand(String command) async {
    await _service.sendCommand(command);
  }

  @override
  Future<Esp32Device> getDeviceInfo() async {
    // Implement based on your ESP32 API
    return Esp32DeviceModel(
      id: 'esp32_1',
      ipAddress: '192.168.1.100',
      port: 81,
      name: 'ESP32 Device',
      lastConnected: DateTime(2026, 5, 3),
      isConnected: false,
    );
  }
}
