import '../../../gestions_des_lots_des_volailles/domain/entities/flock_lot.dart';
import '../entities/vaccination_plan.dart';
import '../inputs/create_vaccination_plan_input.dart';
import '../inputs/record_vaccination_input.dart';

abstract class VaccinationRepository {
  Stream<List<FlockLot>> watchActiveLots();

  Stream<List<VaccinationPlan>> watchPlans(String lotId);

  Future<void> createPlan(CreateVaccinationPlanInput input);

  Future<void> recordVaccination(RecordVaccinationInput input);
}
