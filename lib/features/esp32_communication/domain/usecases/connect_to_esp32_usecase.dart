import '../repositories/esp32_repository.dart';

class ConnectToEsp32UseCase {
  final Esp32Repository repository;

  ConnectToEsp32UseCase(this.repository);

  Future<bool> call(String ipAddress, int port) async {
    return await repository.connectToDevice(ipAddress, port);
  }
}
