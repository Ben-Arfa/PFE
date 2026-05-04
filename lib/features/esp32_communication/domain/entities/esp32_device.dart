class Esp32Device {
  final String id;
  final String ipAddress;
  final int port;
  final String name;
  final DateTime lastConnected;
  final bool isConnected;

  const Esp32Device({
    required this.id,
    required this.ipAddress,
    required this.port,
    required this.name,
    required this.lastConnected,
    required this.isConnected,
  });

  Esp32Device copyWith({
    String? id,
    String? ipAddress,
    int? port,
    String? name,
    DateTime? lastConnected,
    bool? isConnected,
  }) {
    return Esp32Device(
      id: id ?? this.id,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      name: name ?? this.name,
      lastConnected: lastConnected ?? this.lastConnected,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
