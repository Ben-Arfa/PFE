import '../entities/close_lot_input.dart';
import '../entities/create_lot_input.dart';
import '../entities/flock_lot.dart';

abstract class LotRepository {
  Stream<List<FlockLot>> watchLots();
  Future<void> createLot(CreateLotInput input);
  Future<void> closeLot(CloseLotInput input);
  Future<void> deleteLot(String lotId);
}
