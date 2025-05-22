part of 'medicine_form_cubit.dart';

class MedicineFormState extends Equatable {
  const MedicineFormState({
    this.id = '',
    this.medicine = '',
    this.dose = 1,
    this.selectedTimes = const [],
    this.selectedDays = const [],
    this.type = MedicineType.capsule,
    this.selectedDay = 0,
    this.isML = true,
    this.weeksCount = 1,
    required this.selectedTime,
    this.startDate,
  });

  final String id;
  final String medicine;
  final int dose;
  final List<String> selectedTimes;
  final List<int> selectedDays;
  final MedicineType type;
  final DateTime selectedTime;
  final int selectedDay;
  final bool isML;
  final int weeksCount;
  final DateTime? startDate;

  MedicineFormState copyWith({
    String? id,
    String? medicine,
    int? dose,
    List<String>? selectedTimes,
    List<int>? selectedDays,
    MedicineType? type,
    DateTime? selectedTime,
    int? selectedDay,
    bool? isML,
    int? weeksCount,
    DateTime? startDate,
  }) {
    return MedicineFormState(
      id: id ?? this.id,
      medicine: medicine ?? this.medicine,
      dose: dose ?? this.dose,
      selectedTimes: selectedTimes ?? this.selectedTimes,
      selectedDays: selectedDays ?? this.selectedDays,
      type: type ?? this.type,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedDay: selectedDay ?? this.selectedDay,
      isML: isML ?? this.isML,
      weeksCount: weeksCount ?? this.weeksCount,
      startDate: startDate ?? this.startDate,
    );
  }

  @override
  List<Object> get props => [
        id,
        medicine,
        dose,
        selectedTimes,
        selectedDays,
        type,
        selectedTime,
        selectedDay,
        isML,
        weeksCount,
        startDate ?? '',
      ];
}
