import 'package:dartz/dartz.dart';

import 'package:mama_pill/core/data/error/failure.dart';
import 'package:mama_pill/core/error/exceptions.dart';
import 'package:mama_pill/features/medicine/data/datasource/remote/medicine_remote_datasource.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/domain/repositories/medicine_repository.dart';

class MedicineRepositoryImpl extends MedicineRepository {
  MedicineRepositoryImpl(this.remoteDataSource);
  final MedicineRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, Unit>> addMedicineSchedule(
      MedicineSchedule dispenser) async {
    try {
      await remoteDataSource.addMedicineSchedule(dispenser);
      return right(unit);
    } catch (e) {
      if (e is ServerException) {
        return left(ServerFailure(message: e.toString()));
      }
      return left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Stream<List<MedicineSchedule>> getAllMedicinesStream(String patientId) {
    return remoteDataSource.getAllMedicinesStream(patientId);
  }

  @override
  Future<Either<Failure, Unit>> deleteMedicineSchedule(
      String dispenserId) async {
    try {
      await remoteDataSource.deleteMedicineSchedule(dispenserId);
      return right(unit);
    } catch (e) {
      return left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMedicineTakenStatus(
      String id, bool taken) async {
    try {
      await remoteDataSource.updateMedicineTakenStatus(id, taken);
      return right(unit);
    } catch (e) {
      return left(ServerFailure(
          message: 'Failed to update medicine status. Please try again.'));
    }
  }
}
