import 'package:mama_pill/features/medicine/domain/entities/schedule.dart';

class ScheduleModel extends Schedule {
  const ScheduleModel({
    required super.times,
    required super.days,
    super.weeksCount = 1,
    super.startDate,
    super.type = ScheduleType.daily,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
        times: List<String>.from(json["times"].map((x) => x)),
        days: List<int>.from(json["days"].map((x) => x)),
        weeksCount: json["weeksCount"] ?? 1,
        startDate: json["startDate"] != null
            ? DateTime.parse(json["startDate"])
            : null,
        type: json["type"] != null
            ? ScheduleType.values.firstWhere(
                (e) => e.toString() == json["type"],
                orElse: () => ScheduleType.daily)
            : ScheduleType.daily,
      );

  @override
  Map<String, dynamic> toJson() => {
        "times": List<dynamic>.from(times.map((x) => x)),
        "days": List<dynamic>.from(days.map((x) => x)),
        "weeksCount": weeksCount,
        "startDate": startDate?.toIso8601String(),
        "type": type.toString(),
      };
}
