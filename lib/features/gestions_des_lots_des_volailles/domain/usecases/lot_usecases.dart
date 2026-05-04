import '../entities/close_lot_input.dart';
import '../entities/create_lot_input.dart';
import '../entities/flock_lot.dart';
import '../repositories/lot_repository.dart';

class LotUseCases {
  final LotRepository repository;

  LotUseCases(this.repository);

  Stream<List<FlockLot>> watchLots() => repository.watchLots();

  Future<void> createLot(CreateLotInput input) => repository.createLot(input);

  Future<void> closeLot(CloseLotInput input) => repository.closeLot(input);
}
