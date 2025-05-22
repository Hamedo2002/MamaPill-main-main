part of 'patient_records_bloc.dart';

abstract class PatientRecordsEvent extends Equatable {
  const PatientRecordsEvent();

  @override
  List<Object?> get props => [];
}

class PatientRecordsRequested extends PatientRecordsEvent {
  const PatientRecordsRequested();
}

class PatientRecordFetched extends PatientRecordsEvent {
  final String patientId;

  const PatientRecordFetched({required this.patientId});

  @override
  List<Object?> get props => [patientId];
}

class PatientRecordSaved extends PatientRecordsEvent {
  final PatientMedicalRecord record;

  const PatientRecordSaved({required this.record});

  @override
  List<Object?> get props => [record];
}

class PatientRecordUpdated extends PatientRecordsEvent {
  final PatientMedicalRecord record;

  const PatientRecordUpdated({required this.record});

  @override
  List<Object?> get props => [record];
}

class PatientRecordDeleted extends PatientRecordsEvent {
  final String recordId;

  const PatientRecordDeleted({required this.recordId});

  @override
  List<Object?> get props => [recordId];
}

class PatientRecordsReceived extends PatientRecordsEvent {
  final List<PatientMedicalRecord> records;

  const PatientRecordsReceived({required this.records});

  @override
  List<Object?> get props => [records];
}
