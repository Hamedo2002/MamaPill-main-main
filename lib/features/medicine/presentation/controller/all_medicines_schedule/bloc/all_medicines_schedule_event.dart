part of 'all_medicines_schedule_bloc.dart';

@immutable
sealed class AllMedicinesScheduleEvent extends Equatable {
  const AllMedicinesScheduleEvent();

  @override
  List<Object?> get props => [];
}

class AllDispensersFetched extends AllMedicinesScheduleEvent {
  final List<MedicineSchedule> dispensers;
  final String? patientId;
  final bool hasError;

  const AllDispensersFetched({
    this.dispensers = const [],
    this.patientId,
    this.hasError = false,
  });

  @override
  List<Object?> get props => [dispensers, patientId, hasError];
}
