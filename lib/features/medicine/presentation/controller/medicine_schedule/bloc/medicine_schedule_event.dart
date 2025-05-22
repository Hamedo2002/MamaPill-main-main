part of 'medicine_schedule_bloc.dart';

abstract class MedicineScheduleEvent extends Equatable {
  const MedicineScheduleEvent();

  @override
  List<Object> get props => [];
}

class MedicineScheduleAdded extends MedicineScheduleEvent {
  const MedicineScheduleAdded({
    required this.medicineSchedule,
  });
  final MedicineSchedule medicineSchedule;

  @override
  List<Object> get props => [medicineSchedule];
}



class MedicineScheduleTaken extends MedicineScheduleEvent {
  final String medicineId;
  final bool taken;

  const MedicineScheduleTaken({
    required this.medicineId,
    required this.taken,
  });

  @override
  List<Object> get props => [medicineId, taken];
}

class MedicineScheduleDeleted extends MedicineScheduleEvent {
  const MedicineScheduleDeleted({
    required this.medicineId,
  });
  final String medicineId;

  @override
  List<Object> get props => [medicineId];
}
