import '../../domain/entities/close_lot_input.dart';
import '../../domain/entities/create_lot_input.dart';
import '../../domain/entities/flock_lot.dart';
import '../../domain/repositories/lot_repository.dart';
import '../services/lot_service.dart';

class LotRepositoryImpl implements LotRepository {
  final LotService _service;

  LotRepositoryImpl(this._service);

  @override
  Future<void> closeLot(CloseLotInput input) => _service.closeLot(input);

  @override
  Future<void> createLot(CreateLotInput input) => _service.createLot(input);

  @override
  Stream<List<FlockLot>> watchLots() => _service.watchLots();

  @override
  Future<void> deleteLot(String lotId) => _service.deleteLot(lotId);
}
