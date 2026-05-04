import '../../../gestions_des_lots_des_volailles/domain/entities/flock_lot.dart';
import '../../domain/entities/vaccination_plan.dart';
import '../../domain/inputs/create_vaccination_plan_input.dart';
import '../../domain/inputs/record_vaccination_input.dart';
import '../../domain/repositories/vaccination_repository.dart';
import '../services/vaccination_service.dart';

class VaccinationRepositoryImpl implements VaccinationRepository {
  final VaccinationService _service;

  VaccinationRepositoryImpl(this._service);

  @override
  Future<void> createPlan(CreateVaccinationPlanInput input) =>
      _service.createPlan(input);

  @override
  Future<void> recordVaccination(RecordVaccinationInput input) =>
      _service.recordVaccination(input);

  @override
  Stream<List<FlockLot>> watchActiveLots() => _service.watchActiveLots();

  @override
  Stream<List<VaccinationPlan>> watchPlans(String lotId) =>
      _service.watchPlans(lotId);
}
