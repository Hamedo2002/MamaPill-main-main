import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/medicine/data/models/schedule_model.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';

class MedicineScheduleModel extends MedicineSchedule {
  const MedicineScheduleModel({
    required String id,
    required int index,
    required String userId,
    required String patientId,
    required String medicine,
    required MedicineType type,
    required int dose,
    required ScheduleModel schedule,
  }) : super(
          id: id,
          index: index,
          userId: userId,
          patientId: patientId,
          medicine: medicine,
          type: type,
          dose: dose,
          schedule: schedule,
        );

  factory MedicineScheduleModel.fromJson(Map<String, dynamic> json) {
    // Ensure all required fields are present
    if (!json.containsKey('id') ||
        !json.containsKey('index') ||
        !json.containsKey('userId') ||
        !json.containsKey('medicine') ||
        !json.containsKey('dose') ||
        !json.containsKey('type') ||
        !json.containsKey('schedule')) {
      throw FormatException(
          'Missing required fields in medicine schedule data');
    }

    return MedicineScheduleModel(
      id: json["id"] as String,
      index: json["index"] as int,
      userId: json["userId"] as String,
      patientId: json["patientId"] as String,
      medicine: json["medicine"] as String,
      dose: json["dose"] as int,
      type: _parseMedicineType(json["type"] as String),
      schedule:
          ScheduleModel.fromJson(json["schedule"] as Map<String, dynamic>),
    );
  }

  static MedicineType _parseMedicineType(String type) {
    switch (type.toLowerCase()) {
      case 'capsule':
        return MedicineType.capsule;
      case 'tablet':
        return MedicineType.tablet;
      case 'liquid':
        return MedicineType.liquid;
      case 'injection':
        return MedicineType.injection;
      default:
        throw FormatException('Invalid medicine type: $type');
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "index": index,
        "userId": userId,
        "patientId": patientId,
        "medicine": medicine,
        "dose": dose,
        "type": type.name,
        "schedule": (schedule as ScheduleModel).toJson(),
      };
}
