import 'package:dartz/dartz.dart';
import 'package:mama_pill/core/data/error/failure.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';

abstract class MedicineRepository {
  Future<Either<Failure, Unit>> addMedicineSchedule(MedicineSchedule dispenser);
  Future<Either<Failure, Unit>> deleteMedicineSchedule(String id);
  Stream<List<MedicineSchedule>> getAllMedicinesStream(String userId);
  Future<Either<Failure, Unit>> updateMedicineTakenStatus(String id, bool taken);
}
