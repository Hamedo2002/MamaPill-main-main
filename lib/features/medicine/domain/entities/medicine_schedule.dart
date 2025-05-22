import 'package:equatable/equatable.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/medicine/domain/entities/schedule.dart';

class MedicineSchedule extends Equatable {
  const MedicineSchedule({
    required this.id,
    required this.index,
    required this.userId,
    required this.patientId,
    required this.medicine,
    required this.dose,
    required this.type,
    required this.schedule,
    this.taken = false,
  });

  final String id;
  final String userId;
  final String patientId;
  final int index;
  final String medicine;
  final MedicineType type;
  final int dose;
  final Schedule schedule;
  final bool taken;

  const MedicineSchedule.empty()
      : id = '',
        index = 0,
        userId = '',
        patientId = '',
        medicine = '',
        type = MedicineType.capsule,
        dose = 0,
        schedule = const Schedule.empty(),
        taken = false;

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "patientId": patientId,
        "index": index,
        "medicine": medicine,
        "dose": dose,
        "type": type.name,
        "schedule": schedule.toJson(),
        "taken": taken,
      };

  @override
  List<Object?> get props =>
      [userId, patientId, index, medicine, type, dose, schedule, id, taken];
}
