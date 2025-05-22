import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/domain/entities/user_profile.dart';

part 'patients_event.dart';
part 'patients_state.dart';

class PatientsBloc extends Bloc<PatientsEvent, PatientsState> {
  PatientsBloc() : super(const PatientsState()) {
    on<PatientsRequested>(_onPatientsRequested);
    on<PatientsUpdated>(_onPatientsUpdated);
    on<PatientsError>(_onPatientsError);
  }

  final _usersCollection = FirebaseFirestore.instance.collection('users');
  StreamSubscription<QuerySnapshot>? _patientsSubscription;

  Future<void> _onPatientsRequested(
    PatientsRequested event,
    Emitter<PatientsState> emit,
  ) async {
    try {
      // Only start loading if we don't have patients yet
      if (state.patients.isEmpty) {
        emit(state.copyWith(status: RequestStatus.loading));
      }

      // Cancel existing subscription
      await _patientsSubscription?.cancel();
      _patientsSubscription = null;

      // Get initial data synchronously
      final snapshot = await _usersCollection
          .where('role', isEqualTo: UserRole.patient.name.toLowerCase())
          .get();

      if (!isClosed) {
        final patients = snapshot.docs.map((doc) {
          final data = doc.data();
          return UserProfile(
            id: doc.id,
            email: data['email'] as String,
            username: data['username'] as String,
            role: UserRole.patient,
            patientId: data['patientId'] as String?,
          );
        }).toList();

        emit(state.copyWith(
          status: RequestStatus.success,
          patients: patients,
        ));

        // Create a separate method to handle stream updates
        // This prevents the emit after completion error
        _setupPatientsSubscription();
      }
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(
          status: RequestStatus.failure,
          error: error.toString(),
        ));
      }
    }
  }

  void _setupPatientsSubscription() {
    // Only set up subscription if it's not already active
    if (_patientsSubscription != null) return;
    
    _patientsSubscription = _usersCollection
        .where('role', isEqualTo: UserRole.patient.name.toLowerCase())
        .snapshots()
        .listen(
      (snapshot) {
        if (isClosed) return;
        
        final patients = snapshot.docs.map((doc) {
          final data = doc.data();
          return UserProfile(
            id: doc.id,
            email: data['email'] as String,
            username: data['username'] as String,
            role: UserRole.patient,
            patientId: data['patientId'] as String?,
          );
        }).toList();

        add(PatientsUpdated(patients));
      },
      onError: (error) {
        if (isClosed) return;
        add(PatientsError(error.toString()));
      },
    );
  }

  void _onPatientsUpdated(PatientsUpdated event, Emitter<PatientsState> emit) {
    emit(state.copyWith(
      status: RequestStatus.success,
      patients: event.patients,
    ));
  }

  void _onPatientsError(PatientsError event, Emitter<PatientsState> emit) {
    emit(state.copyWith(
      status: RequestStatus.failure,
      error: event.error,
    ));
  }

  @override
  Future<void> close() async {
    await _patientsSubscription?.cancel();
    return super.close();
  }
}
