part of 'patients_bloc.dart';

class PatientsState extends Equatable {
  const PatientsState({
    this.status = RequestStatus.initial,
    this.patients = const [],
    this.error,
  });

  final RequestStatus status;
  final List<UserProfile> patients;
  final String? error;

  PatientsState copyWith({
    RequestStatus? status,
    List<UserProfile>? patients,
    String? error,
  }) {
    return PatientsState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, patients, error];
}
