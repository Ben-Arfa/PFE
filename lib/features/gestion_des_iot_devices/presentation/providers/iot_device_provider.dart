import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/iot_device_repository.dart';
import '../../data/services/esp32_dht22_service.dart';
import '../../data/datasources/iot_device_remote_data_source.dart';
import '../../data/repositories/iot_device_repository_impl.dart';

// Firebase instances providers
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Data source provider
final iotDeviceRemoteDataSourceProvider = Provider<IotDeviceRemoteDataSource>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return IotDeviceRemoteDataSource(firestore: firestore, auth: auth);
});

// Repository provider
final iotDeviceRepositoryProvider = Provider<IotDeviceRepository>((ref) {
  final dataSource = ref.watch(iotDeviceRemoteDataSourceProvider);
  return IotDeviceRepositoryImpl(dataSource);
});

final esp32Dht22ServiceProvider = Provider<Esp32Dht22Service>((ref) {
  return Esp32Dht22Service();
});

// Watch all devices
final iotDevicesStreamProvider = StreamProvider<List<IotDevice>>((ref) async* {
  final repository = ref.watch(iotDeviceRepositoryProvider);
  yield* repository.watchAllDevices();
});

// Watch devices for a specific building
final iotBuildingDevicesStreamProvider =
    StreamProvider.family<List<IotDevice>, String>((ref, buildingId) async* {
      final repository = ref.watch(iotDeviceRepositoryProvider);
      yield* repository.watchBuildingDevices(buildingId);
    });

// Watch a single device
final iotDeviceStreamProvider = StreamProvider.family<IotDevice?, String>((
  ref,
  deviceId,
) async* {
  final repository = ref.watch(iotDeviceRepositoryProvider);
  yield* repository.watchDevice(deviceId);
});

// Watch device readings
final iotDeviceReadingsStreamProvider =
    StreamProvider.family<List<SensorReading>, (String deviceId, int limit)>((
      ref,
      params,
    ) async* {
      final repository = ref.watch(iotDeviceRepositoryProvider);
      yield* repository.watchDeviceReadings(params.$1, limit: params.$2);
    });

// Create device state notifier
class CreateDeviceNotifier extends StateNotifier<AsyncValue<void>> {
  final IotDeviceRepository _repository;

  CreateDeviceNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<String> createDevice(IotDevice device) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createDevice(device));
    if (state.hasError) {
      return '';
    }
    return device.id;
  }
}

final createIotDeviceProvider =
    StateNotifierProvider<CreateDeviceNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(iotDeviceRepositoryProvider);
      return CreateDeviceNotifier(repository);
    });

// Update device state notifier
class UpdateDeviceNotifier extends StateNotifier<AsyncValue<void>> {
  final IotDeviceRepository _repository;

  UpdateDeviceNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> updateDevice(IotDevice device) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateDevice(device));
  }
}

final updateIotDeviceProvider =
    StateNotifierProvider<UpdateDeviceNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(iotDeviceRepositoryProvider);
      return UpdateDeviceNotifier(repository);
    });

// Delete device state notifier
class DeleteDeviceNotifier extends StateNotifier<AsyncValue<void>> {
  final IotDeviceRepository _repository;

  DeleteDeviceNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> deleteDevice(String deviceId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteDevice(deviceId));
  }
}

final deleteIotDeviceProvider =
    StateNotifierProvider<DeleteDeviceNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(iotDeviceRepositoryProvider);
      return DeleteDeviceNotifier(repository);
    });

// Record sensor reading
class RecordReadingNotifier extends StateNotifier<AsyncValue<void>> {
  final IotDeviceRepository _repository;

  RecordReadingNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> recordReading(SensorReading reading) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.recordReading(reading));
  }
}

final recordSensorReadingProvider =
    StateNotifierProvider<RecordReadingNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(iotDeviceRepositoryProvider);
      return RecordReadingNotifier(repository);
    });

class SyncEsp32ReadingNotifier extends StateNotifier<AsyncValue<void>> {
  final IotDeviceRepository _repository;
  final Esp32Dht22Service _esp32Service;

  SyncEsp32ReadingNotifier(this._repository, this._esp32Service)
    : super(const AsyncValue.data(null));

  Future<void> syncDevice(IotDevice device) async {
    final esp32Url = device.metadata['esp32Url'] as String?;
    if (esp32Url == null || esp32Url.trim().isEmpty) {
      throw Exception('Adresse ESP32 manquante');
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final reading = await _esp32Service.fetchReading(
        baseUrl: esp32Url,
        deviceId: device.id,
      );
      await _repository.recordReading(reading);
    });

    if (state.hasError) {
      throw state.error!;
    }
  }
}

final syncEsp32ReadingProvider =
    StateNotifierProvider<SyncEsp32ReadingNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(iotDeviceRepositoryProvider);
      final esp32Service = ref.watch(esp32Dht22ServiceProvider);
      return SyncEsp32ReadingNotifier(repository, esp32Service);
    });
