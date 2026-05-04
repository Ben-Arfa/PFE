import '../entities/sensor_data.dart';
import '../repositories/esp32_repository.dart';

class WatchSensorDataUseCase {
  final Esp32Repository repository;

  WatchSensorDataUseCase(this.repository);

  Stream<SensorData> call(String sensorId) {
    return repository.watchSensorData(sensorId);
  }
}
