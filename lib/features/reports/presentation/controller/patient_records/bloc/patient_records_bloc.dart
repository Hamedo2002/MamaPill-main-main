import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/reports/domain/entities/patient_medical_record.dart';
import 'package:mama_pill/features/reports/domain/repository/patient_records_repository.dart';

part 'patient_records_event.dart';
part 'patient_records_state.dart';

class PatientRecordsBloc extends Bloc<PatientRecordsEvent, PatientRecordsState> {
  final PatientRecordsRepository repository;
  StreamSubscription<List<PatientMedicalRecord>>? _recordsSubscription;

  PatientRecordsBloc({required this.repository}) : super(const PatientRecordsState()) {
    on<PatientRecordsRequested>(_onPatientRecordsRequested);
    on<PatientRecordFetched>(_onPatientRecordFetched);
    on<PatientRecordSaved>(_onPatientRecordSaved);
    on<PatientRecordUpdated>(_onPatientRecordUpdated);
    on<PatientRecordDeleted>(_onPatientRecordDeleted);
    on<PatientRecordsReceived>(_onPatientRecordsReceived);
  }

  Future<void> _onPatientRecordsRequested(
    PatientRecordsRequested event,
    Emitter<PatientRecordsState> emit,
  ) async {
    try {
      // Only start loading if we don't have records yet
      if (state.records.isEmpty) {
        emit(state.copyWith(status: RequestStatus.loading));
      }

      // Cancel existing subscription
      await _recordsSubscription?.cancel();

      // Subscribe to patient records stream
      _recordsSubscription = repository.getAllPatientRecordsStream().listen(
        (records) {
          if (!isClosed) {
            add(PatientRecordsReceived(records: records));
          }
        },
        onError: (error) {
          if (!isClosed) {
            emit(state.copyWith(
              status: RequestStatus.failure,
              message: error.toString(),
            ));
          }
        },
      );
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(
          status: RequestStatus.failure,
          message: error.toString(),
        ));
      }
    }
  }

  Future<void> _onPatientRecordFetched(
    PatientRecordFetched event,
    Emitter<PatientRecordsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: RequestStatus.loading));
      
      final record = await repository.getPatientRecord(event.patientId);
      
      if (record != null) {
        emit(state.copyWith(
          status: RequestStatus.success,
          selectedRecord: record,
        ));
      } else {
        emit(state.copyWith(
          status: RequestStatus.success,
          selectedRecord: null,
          message: 'No medical record found for this patient',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: RequestStatus.failure,
        message: error.toString(),
      ));
    }
  }

  Future<void> _onPatientRecordSaved(
    PatientRecordSaved event,
    Emitter<PatientRecordsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: RequestStatus.loading));
      
      await repository.savePatientRecord(event.record);
      
      emit(state.copyWith(
        status: RequestStatus.success,
        message: 'Patient record saved successfully',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RequestStatus.failure,
        message: 'Failed to save patient record: ${error.toString()}',
      ));
    }
  }

  Future<void> _onPatientRecordUpdated(
    PatientRecordUpdated event,
    Emitter<PatientRecordsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: RequestStatus.loading));
      
      await repository.updatePatientRecord(event.record);
      
      emit(state.copyWith(
        status: RequestStatus.success,
        message: 'Patient record updated successfully',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RequestStatus.failure,
        message: 'Failed to update patient record: ${error.toString()}',
      ));
    }
  }

  Future<void> _onPatientRecordDeleted(
    PatientRecordDeleted event,
    Emitter<PatientRecordsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: RequestStatus.loading));
      
      await repository.deletePatientRecord(event.recordId);
      
      emit(state.copyWith(
        status: RequestStatus.success,
        message: 'Patient record deleted successfully',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RequestStatus.failure,
        message: 'Failed to delete patient record: ${error.toString()}',
      ));
    }
  }

  void _onPatientRecordsReceived(
    PatientRecordsReceived event,
    Emitter<PatientRecordsState> emit,
  ) {
    emit(state.copyWith(
      status: RequestStatus.success,
      records: event.records,
    ));
  }

  @override
  Future<void> close() async {
    await _recordsSubscription?.cancel();
    return super.close();
  }
}
