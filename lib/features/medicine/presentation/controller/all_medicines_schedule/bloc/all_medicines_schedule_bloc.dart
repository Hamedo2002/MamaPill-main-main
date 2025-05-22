import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/domain/usecases/get_all_medicines_stream_usecase.dart';

part 'all_medicines_schedule_event.dart';
part 'all_medicines_schedule_state.dart';

class AllMedicinesScheduleBloc
    extends Bloc<AllMedicinesScheduleEvent, AllMedicinesScheduleState> {
  final AuthBloc authBloc;
  late StreamSubscription<AuthState> authSubscription;
  final GetDispenserStreamUseCase getDispenserStreamUseCase;
  StreamSubscription<List<MedicineSchedule>>? patientSubscription;

  bool _isClosed = false;
  bool _isSubscriptionActive = true;
  String? _currentPatientId;

  AllMedicinesScheduleBloc(
    this.authBloc,
    this.getDispenserStreamUseCase,
  ) : super(const AllMedicinesScheduleState()) {
    on<AllDispensersFetched>(_onAllDispensersFetched);

    // Start listening to medicines based on user role
    final currentUser = authBloc.state.user;
    if (currentUser.id != null && currentUser.id!.isNotEmpty) {
      startListeningToMedicines(currentUser.id!);
    }

    // Listen for auth state changes
    authSubscription = authBloc.stream.listen((authState) {
      if (!_isClosed &&
          authState.user.id != null &&
          authState.user.id!.isNotEmpty) {
        startListeningToMedicines(authState.user.id!);
      }
    });
  }

  void startListeningToMedicines(String userId, [String? patientId]) {
    // Cancel existing subscription if any
    patientSubscription?.cancel();

    // Don't start a new subscription if the bloc is closed
    if (_isClosed) {
      print('Bloc is closed, not starting new subscription');
      return;
    }

    print('Starting to listen to medicines for user: $userId');
    print('Current user role: ${authBloc.state.user.role.name}');
    
    // Update current patient ID before starting the subscription
    if (patientId != null) {
      _currentPatientId = patientId;
      print('Filtering for patient ID: $patientId');
    }

    // Reset subscription state
    _isSubscriptionActive = true;

    // Start new subscription
    patientSubscription = getDispenserStreamUseCase(userId).listen(
      (medicines) {
        print('Received medicines: ${medicines.length}');

        // Only add event if bloc is not closed and subscription is active
        if (!_isClosed && _isSubscriptionActive) {
          // Don't filter here - let _onAllDispensersFetched handle the filtering
          // based on user role and current patient ID
          add(AllDispensersFetched(
            dispensers: medicines,
            patientId: _currentPatientId,
          ));
        } else {
          print('Skipping event - bloc is closed or subscription inactive');
        }
      },
      onError: (error) {
        print('Error in medicine stream: $error');
        if (!_isClosed && _isSubscriptionActive) {
          add(const AllDispensersFetched(dispensers: [], hasError: true));
        }
      },
    );
  }

  Future<void> _onAllDispensersFetched(
    AllDispensersFetched event,
    Emitter<AllMedicinesScheduleState> emit,
  ) async {
    if (event.hasError) {
      print('Error fetching medicines');
      emit(state.copyWith(status: RequestStatus.failure));
      return;
    }

    // Get all medicines from the event
    final allMedicines = event.dispensers;
    print('All medicines before filtering: ${allMedicines.length}');
    
    // Update current patient ID from event if provided
    if (event.patientId != null && event.patientId != _currentPatientId) {
      _currentPatientId = event.patientId;
      print('Updated current patient ID to: $_currentPatientId');
    }
    
    final userRole = authBloc.state.user.role.name.toLowerCase();
    
    // Variable to hold final medicines list
    List<MedicineSchedule> filteredMedicines = [];
    
    // Get current user role
    print('Processing medicines for user role: $userRole');

    // For doctor role, only show medicines when a patient is selected
    if (userRole == 'doctor') {
      if (_currentPatientId != null && _currentPatientId!.isNotEmpty) {
        print('Doctor filtering for patient ID: $_currentPatientId');
        filteredMedicines = allMedicines.where(
          (medicine) => medicine.patientId == _currentPatientId).toList();
      } else {
        // Show no medicines if no patient is selected
        print('Doctor - no patient selected, showing no medicines');
        filteredMedicines = [];
      }
    }
    // For staff role, only show medicines when a patient is selected
    else if (userRole == 'staff') {
      if (_currentPatientId != null && _currentPatientId!.isNotEmpty) {
        print('Staff filtering for patient ID: $_currentPatientId');
        filteredMedicines = allMedicines.where(
          (medicine) => medicine.patientId == _currentPatientId).toList();
      } else {
        // Show no medicines if no patient is selected
        print('Staff - no patient selected, showing no medicines');
        filteredMedicines = [];
      }
    }
    // For patient role
    else {
      filteredMedicines = allMedicines;
      print('Patient role - showing all medicines');
    }

    print('Updating state with ${filteredMedicines.length} medicines');
    emit(
      state.copyWith(
        status: RequestStatus.success,
        dispensers: filteredMedicines,
      ),
    );
  }

  @override
  Future<void> close() async {
    // Mark as closed and deactivate subscription before canceling
    _isClosed = true;
    _isSubscriptionActive = false;
    
    // Cancel subscriptions
    await patientSubscription?.cancel();
    patientSubscription = null;
    await authSubscription.cancel();
    
    return super.close();
  }
}
