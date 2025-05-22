import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/domain/usecases/add_medicine_schedule_usecase.dart';
import 'package:mama_pill/features/medicine/domain/usecases/delete_medicine_schedule_usecase.dart';
import 'package:mama_pill/features/medicine/domain/repositories/medicine_repository.dart';

part 'medicine_schedule_event.dart';
part 'medicine_schedule_state.dart';

class MedicineScheduleBloc extends Bloc<MedicineScheduleEvent, MedicineScheduleState> {
  final AddPatientDataUseCase addPatientDataUseCase;
  final DeleteDispenserUseCase deleteDispenserUseCase;
  final MedicineRepository _repository;

  MedicineScheduleBloc(
    this.addPatientDataUseCase,
    this.deleteDispenserUseCase,
    this._repository,
  ) : super(const MedicineScheduleState()) {
    on<MedicineScheduleAdded>(_onMedicineScheduleAdded);
    on<MedicineScheduleDeleted>(_onMedicineScheduleDeleted);
    on<MedicineScheduleTaken>(_onMedicineScheduleTaken);
  }

  FutureOr<void> _onMedicineScheduleAdded(
      MedicineScheduleAdded event, Emitter<MedicineScheduleState> emit) async {
    emit(state.copyWith(saveStatus: RequestStatus.loading));
    
    try {
      final result = await addPatientDataUseCase(event.medicineSchedule);
      
      await result.fold(
        (failure) async {
          emit(state.copyWith(
            saveStatus: RequestStatus.failure,
            message: failure.message ?? 'Failed to add medicine',
            shouldShowNotification: true,
            notificationType: NotificationType.error,
            notificationMessage: failure.message ?? 'Failed to update medicine. Please try again.'
          ));
        },
        (_) async {
          emit(state.copyWith(
            saveStatus: RequestStatus.success,
            message: 'Medicine updated successfully',
            shouldShowNotification: true,
            notificationType: NotificationType.success,
            notificationMessage: '${event.medicineSchedule.medicine} has been updated successfully!'
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        saveStatus: RequestStatus.failure,
        message: 'An unexpected error occurred',
        shouldShowNotification: true,
        notificationType: NotificationType.error,
        notificationMessage: 'An unexpected error occurred. Please try again.'
      ));
    }
  }



  FutureOr<void> _onMedicineScheduleTaken(
    MedicineScheduleTaken event,
    Emitter<MedicineScheduleState> emit,
  ) async {
    emit(state.copyWith(saveStatus: RequestStatus.loading));

    final result = await _repository.updateMedicineTakenStatus(
      event.medicineId,
      event.taken,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        saveStatus: RequestStatus.failure,
        message: failure.message,
        shouldShowNotification: true,
        notificationType: NotificationType.error,
        notificationMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        saveStatus: RequestStatus.success,
        message: event.taken ? 'Medicine marked as taken' : 'Medicine status updated',
        shouldShowNotification: true,
        notificationType: event.taken ? NotificationType.success : NotificationType.info,
        notificationMessage: event.taken
            ? 'Medicine marked as taken successfully!'
            : 'Medicine status updated',
      )),
    );
  }

  FutureOr<void> _onMedicineScheduleDeleted(MedicineScheduleDeleted event,
      Emitter<MedicineScheduleState> emit) async {
    emit(state.copyWith(deleteStatus: RequestStatus.loading));
    final result = await deleteDispenserUseCase(event.medicineId);
    result.fold(
      (failure) => emit(state.copyWith(deleteStatus: RequestStatus.failure)),
      (_) => emit(state.copyWith(deleteStatus: RequestStatus.success)),
    );
  }
}
