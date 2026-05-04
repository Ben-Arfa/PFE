import '../entities/poultry_type.dart';
import '../entities/poultry_type_input.dart';

abstract class PoultryTypeRepository {
  Stream<List<PoultryType>> watchAll();
  Future<void> create(PoultryTypeInput input);
  Future<void> update(String id, PoultryTypeInput input);
  Future<void> delete(String id);
}
