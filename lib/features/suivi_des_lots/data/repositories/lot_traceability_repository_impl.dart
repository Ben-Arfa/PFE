import '../../domain/entities/create_lot_history_event_input.dart';
import '../../domain/entities/lot_history_event.dart';
import '../../domain/repositories/lot_traceability_repository.dart';
import '../services/lot_traceability_service.dart';

class LotTraceabilityRepositoryImpl implements LotTraceabilityRepository {
  final LotTraceabilityService _service;

  LotTraceabilityRepositoryImpl(this._service);

  @override
  Future<void> addEvent(CreateLotHistoryEventInput input) =>
      _service.addEvent(input);

  @override
  Stream<List<LotHistoryEvent>> watchEvents(String lotId) =>
      _service.watchEvents(lotId);
}
