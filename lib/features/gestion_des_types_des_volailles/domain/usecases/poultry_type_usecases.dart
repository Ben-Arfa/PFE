import '../entities/poultry_type.dart';
import '../entities/poultry_type_input.dart';
import '../repositories/poultry_type_repository.dart';

class PoultryTypeUseCases {
  final PoultryTypeRepository repository;

  PoultryTypeUseCases(this.repository);

  Stream<List<PoultryType>> watchAll() => repository.watchAll();

  Future<void> create(PoultryTypeInput input) => repository.create(input);

  Future<void> update(String id, PoultryTypeInput input) =>
      repository.update(id, input);

  Future<void> delete(String id) => repository.delete(id);
}
