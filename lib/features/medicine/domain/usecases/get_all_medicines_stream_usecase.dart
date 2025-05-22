import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/domain/repositories/medicine_repository.dart';

class GetDispenserStreamUseCase {
  final MedicineRepository repository;

  GetDispenserStreamUseCase(this.repository);

  Stream<List<MedicineSchedule>> call(String patientId) {
    return repository.getAllMedicinesStream(patientId);
  }
}
