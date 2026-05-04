import '../entities/create_lot_history_event_input.dart';
import '../entities/lot_history_event.dart';

abstract class LotTraceabilityRepository {
  Stream<List<LotHistoryEvent>> watchEvents(String lotId);

  Future<void> addEvent(CreateLotHistoryEventInput input);
}
