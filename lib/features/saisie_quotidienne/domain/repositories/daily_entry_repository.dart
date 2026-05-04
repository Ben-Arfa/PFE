import '../entities/daily_entry.dart';
import '../inputs/create_daily_entry_input.dart';

abstract class DailyEntryRepository {
  Stream<List<DailyEntry>> watchEntriesForLot(String lotId);

  Future<void> createEntry(CreateDailyEntryInput input);

  Future<void> deleteEntry(String lotId, String entryId);
}
