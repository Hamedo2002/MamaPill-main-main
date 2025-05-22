part of 'patients_bloc.dart';

abstract class PatientsEvent extends Equatable {
  const PatientsEvent();

  @override
  List<Object?> get props => [];
}

class PatientsRequested extends PatientsEvent {
  const PatientsRequested();
}

class PatientsUpdated extends PatientsEvent {
  final List<UserProfile> patients;
  
  const PatientsUpdated(this.patients);
  
  @override
  List<Object?> get props => [patients];
}

class PatientsError extends PatientsEvent {
  final String error;
  
  const PatientsError(this.error);
  
  @override
  List<Object?> get props => [error];
}
