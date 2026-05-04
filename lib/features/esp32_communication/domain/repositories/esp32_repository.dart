import '../entities/esp32_device.dart';
import '../entities/sensor_data.dart';

abstract class Esp32Repository {
  Future<bool> connectToDevice(String ipAddress, int port);
  Future<void> disconnect();
  Future<bool> isConnected();
  Stream<SensorData> watchSensorData(String sensorId);
  Future<List<SensorData>> fetchLatestSensorData();
  Future<void> sendCommand(String command);
  Future<Esp32Device> getDeviceInfo();
}
