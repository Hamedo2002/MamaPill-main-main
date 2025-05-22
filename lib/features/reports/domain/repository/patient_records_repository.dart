import 'package:mama_pill/features/reports/domain/entities/patient_medical_record.dart';

abstract class PatientRecordsRepository {
  // Get a stream of all patient records
  Stream<List<PatientMedicalRecord>> getAllPatientRecordsStream();
  
  // Get a specific patient's medical record
  Future<PatientMedicalRecord?> getPatientRecord(String patientId);
  
  // Save a patient's medical record
  Future<void> savePatientRecord(PatientMedicalRecord record);
  
  // Update a patient's medical record
  Future<void> updatePatientRecord(PatientMedicalRecord record);
  
  // Delete a patient's medical record
  Future<void> deletePatientRecord(String id);
}
