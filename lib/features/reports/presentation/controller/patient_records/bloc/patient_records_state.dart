part of 'patient_records_bloc.dart';

class PatientRecordsState extends Equatable {
  final RequestStatus status;
  final List<PatientMedicalRecord> records;
  final PatientMedicalRecord? selectedRecord;
  final String? message;

  const PatientRecordsState({
    this.status = RequestStatus.initial,
    this.records = const [],
    this.selectedRecord,
    this.message,
  });

  PatientRecordsState copyWith({
    RequestStatus? status,
    List<PatientMedicalRecord>? records,
    PatientMedicalRecord? selectedRecord,
    String? message,
  }) {
    return PatientRecordsState(
      status: status ?? this.status,
      records: records ?? this.records,
      selectedRecord: selectedRecord ?? this.selectedRecord,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, records, selectedRecord, message];
}
