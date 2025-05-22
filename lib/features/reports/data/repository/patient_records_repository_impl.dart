import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/reports/domain/entities/patient_medical_record.dart';
import 'package:mama_pill/features/reports/domain/repository/patient_records_repository.dart';

class PatientRecordsRepositoryImpl implements PatientRecordsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PatientRecordsRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Gets the current user's role from Firestore
  Future<UserRole> _getCurrentUserRole() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final data = userDoc.data();
      if (data == null) {
        throw Exception('User data is null');
      }

      final String roleStr = (data['role'] as String).toLowerCase();
      switch (roleStr) {
        case 'doctor':
          return UserRole.doctor;
        case 'staff':
          return UserRole.staff;
        case 'patient':
          return UserRole.patient;
        default:
          return UserRole.patient;
      }
    } catch (e) {
      print('Error getting user role: $e');
      // Default to patient (most restrictive) on error
      return UserRole.patient;
    }
  }

  @override
  Stream<List<PatientMedicalRecord>> getAllPatientRecordsStream() {
    // Everyone can read patient records list
    return _firestore
        .collection('patient_records')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PatientMedicalRecord.fromFirestore(doc))
            .toList());
  }

  @override
  Future<PatientMedicalRecord?> getPatientRecord(String patientId) async {
    // All users can read patient records
    try {
      final snapshot = await _firestore
          .collection('patient_records')
          .where('patientId', isEqualTo: patientId)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return PatientMedicalRecord.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting patient record: $e');
      return null;
    }
  }

  @override
  Future<void> savePatientRecord(PatientMedicalRecord record) async {
    // Only doctors and staff can create records
    final userRole = await _getCurrentUserRole();
    if (userRole == UserRole.patient) {
      throw Exception('Permission denied: Patients cannot create medical records');
    }
    
    try {
      await _firestore.collection('patient_records').add(record.toFirestore());
    } catch (e) {
      print('Error saving patient record: $e');
      throw Exception('Failed to save patient record: $e');
    }
  }

  @override
  Future<void> updatePatientRecord(PatientMedicalRecord record) async {
    // Only doctors and staff can update records
    final userRole = await _getCurrentUserRole();
    if (userRole == UserRole.patient) {
      throw Exception('Permission denied: Patients cannot update medical records');
    }
    
    if (record.id == null) {
      throw Exception('Cannot update record without an ID');
    }

    try {
      await _firestore
          .collection('patient_records')
          .doc(record.id)
          .update(record.toFirestore());
    } catch (e) {
      print('Error updating patient record: $e');
      throw Exception('Failed to update patient record: $e');
    }
  }

  @override
  Future<void> deletePatientRecord(String id) async {
    // Only doctors and staff can delete records
    final userRole = await _getCurrentUserRole();
    if (userRole == UserRole.patient) {
      throw Exception('Permission denied: Patients cannot delete medical records');
    }
    
    try {
      await _firestore.collection('patient_records').doc(id).delete();
    } catch (e) {
      print('Error deleting patient record: $e');
      throw Exception('Failed to delete patient record: $e');
    }
  }
}
