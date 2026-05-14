import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/iot_device_repository.dart';
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
