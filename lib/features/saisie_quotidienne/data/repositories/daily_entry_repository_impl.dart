import '../../domain/entities/daily_entry.dart';
import '../../domain/inputs/create_daily_entry_input.dart';
import '../../domain/repositories/daily_entry_repository.dart';
import '../services/daily_entry_service.dart';

class DailyEntryRepositoryImpl implements DailyEntryRepository {
  final DailyEntryService _service;

  DailyEntryRepositoryImpl(this._service);

  @override
  Future<void> createEntry(CreateDailyEntryInput input) =>
      _service.createEntry(input);

  @override
  Stream<List<DailyEntry>> watchEntriesForLot(String lotId) =>
      _service.watchEntries(lotId);

  @override
  Future<void> deleteEntry(String lotId, String entryId) =>
      _service.deleteEntry(lotId, entryId);
}
