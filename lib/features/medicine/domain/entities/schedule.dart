import 'package:equatable/equatable.dart';

enum ScheduleType {
  daily,
  weekly,
}

class Schedule extends Equatable {
  const Schedule({
    required this.times,
    required this.days,
    this.weeksCount = 1,
    this.startDate,
    this.type = ScheduleType.daily,
  });

  final List<String> times;
  final List<int> days;
  final int weeksCount;
  final DateTime? startDate;
  final ScheduleType type;
  int get frequency => weeksCount;

  const Schedule.empty()
      : times = const [],
        days = const [],
        weeksCount = 1,
        startDate = null,
        type = ScheduleType.daily;

  Map<String, dynamic> toJson() => {
        "times": List<dynamic>.from(times.map((x) => x)),
        "days": List<dynamic>.from(days.map((x) => x)),
        "weeksCount": weeksCount,
        "startDate": startDate?.toIso8601String(),
        "type": type.toString(),
      };

  @override
  List<Object?> get props => [times, days, weeksCount, startDate, type];
}
