import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dartz/dartz.dart';
import 'package:mama_pill/core/error/exceptions.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/medicine/data/models/medicne_schedule_model.dart';
import 'package:mama_pill/features/medicine/data/models/schedule_model.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';

abstract class MedicineRemoteDataSource {
  Future<Unit> addMedicineSchedule(MedicineSchedule dispenser);
  Future<Unit> deleteMedicineSchedule(String id);
  Stream<List<MedicineSchedule>> getAllMedicinesStream(String userId);
  Future<Unit> updateMedicineTakenStatus(String id, bool taken);
}

class MedicineRemoteDataSourceImpl implements MedicineRemoteDataSource {
  MedicineRemoteDataSourceImpl();

  final CollectionReference dispenserMedicineCollection =
      FirebaseFirestore.instance.collection('dispenser_medicine');
  final CollectionReference medicineCollection =
      FirebaseFirestore.instance.collection('medicine');
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Future<Unit> updateMedicineTakenStatus(String id, bool taken) async {
    try {
      // Try to update in dispenser_medicine collection first
      await dispenserMedicineCollection.doc(id).update({'taken': taken});
      return unit;
    } catch (e) {
      try {
        // If not found in dispenser_medicine, try medicine collection
        await medicineCollection.doc(id).update({'taken': taken});
        return unit;
      } catch (e) {
        throw ServerException('Failed to update medicine status');
      }
    }
  }

  @override
  Stream<List<MedicineSchedule>> getAllMedicinesStream(String userId) async* {
    try {
      print('========== DEBUG: Medicine Query Start ==========');
      print('Querying medicines for user ID: $userId');

      // First get the user's role and patient ID if applicable
      final userDoc = await usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        print('ERROR: User document not found for ID: $userId');
        yield [];
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      print('Raw user data from Firestore: $userData');

      final userRole = userData['role'] as String;
      final patientId = userData['patientId'] as String?;

      print('User Role: $userRole');
      print('Patient ID from Firestore: $patientId');

      // For patients, only show their medicines using their patientId
      if (userRole.toLowerCase() == 'patient') {
        // If the patientId field is missing, use the user's own ID as the patientId
        final effectivePatientId = (patientId == null || patientId.isEmpty) ? userId : patientId;
        print('Patient user detected - using effective patient ID: $effectivePatientId');
        yield* _getMedicinesForPatient(effectivePatientId);
      }
      // For doctors and staff, show all medicines
      else {
        print('Fetching all medicines for ${userRole.toLowerCase()}');
        yield* _getAllMedicines();
      }
    } catch (e, stack) {
      print('ERROR in getAllMedicinesStream: $e');
      print('Stack trace: $stack');
      yield [];
    }
  }

  Stream<List<MedicineSchedule>> _getMedicinesForPatient(String patientId) {
    try {
      print('========== DEBUG: Patient Medicine Query ==========');
      print('Querying medicines for patient ID: $patientId');

      // Query dispenser medicines collection without complex ordering
      // This avoids the need for a composite index
      final dispenserStream = dispenserMedicineCollection
          .where('patientId', isEqualTo: patientId)
          .snapshots()
          .map((snapshot) {
        print('Dispenser medicines query result:');
        print('- Number of documents found: ${snapshot.docs.length}');
        if (snapshot.docs.isEmpty) {
          print('- No dispenser medicines found for patient $patientId');
        } else {
          print('- Found medicines:');
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            print(
                '  * Medicine: ${data['medicine']}, Patient ID: ${data['patientId']}');
          }
        }

        final medicines = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return MedicineScheduleModel.fromJson(data);
        }).toList();

        return medicines;
      }).handleError((error) {
        print('ERROR in dispenser medicines query: $error');
        if (error is FirebaseException) {
          print('Firebase error code: ${error.code}');
          print('Firebase error message: ${error.message}');
        }
        return <MedicineSchedule>[];
      });

      // Simplified query without ordering to avoid needing a composite index
      final medicineStream = medicineCollection
          .where('patientId', isEqualTo: patientId)
          .snapshots()
          .map((snapshot) {
        print('Regular medicines query result:');
        print('- Number of documents found: ${snapshot.docs.length}');
        if (snapshot.docs.isEmpty) {
          print('- No regular medicines found for patient $patientId');
        } else {
          print('- Found medicines:');
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            print(
                '  * Medicine: ${data['medicine']}, Patient ID: ${data['patientId']}');
          }
        }

        final medicines = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return MedicineScheduleModel.fromJson(data);
        }).toList();

        return medicines;
      }).handleError((error) {
        print('ERROR in regular medicines query: $error');
        if (error is FirebaseException) {
          print('Firebase error code: ${error.code}');
          print('Firebase error message: ${error.message}');
        }
        return <MedicineSchedule>[];
      });

      // Combine both streams
      return Rx.combineLatest2<List<MedicineSchedule>, List<MedicineSchedule>,
          List<MedicineSchedule>>(
        dispenserStream,
        medicineStream,
        (dispenserMeds, otherMeds) {
          final allMeds = [...dispenserMeds, ...otherMeds];
          print('========== DEBUG: Combined Results ==========');
          print('Total medicines found: ${allMeds.length}');
          if (allMeds.isEmpty) {
            print('No medicines found in either collection');
          } else {
            print('Found medicines:');
            for (var med in allMeds) {
              print(
                  '* ${med.medicine} (${med.type}) - Patient ID: ${med.patientId}');
            }
          }
          return allMeds;
        },
      ).handleError((error) {
        print('ERROR in combined stream: $error');
        if (error is FirebaseException) {
          print('Firebase error code: ${error.code}');
          print('Firebase error message: ${error.message}');
        }
        return <MedicineSchedule>[];
      });
    } catch (e, stack) {
      print('ERROR in _getMedicinesForPatient: $e');
      print('Stack trace: $stack');
      return Stream.value([]);
    }
  }

  Stream<List<MedicineSchedule>> _getAllMedicines() {
    try {
      print('_getAllMedicines called - GETTING ALL MEDICINES FOR DOCTOR/STAFF');

      // Query dispenser medicines collection (for tablets and capsules)
      // No filtering or ordering to ensure all medicines are visible to doctors
      final dispenserStream = dispenserMedicineCollection
          .snapshots()
          .map((snapshot) {
        print('All dispenser medicines found: ${snapshot.docs.length}');
        final medicines = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          print(
              'Processing dispenser medicine: ${data['medicine']} for patient ${data['patientId']}');
          print('Full medicine data: $data');
          return MedicineScheduleModel.fromJson(data);
        }).toList();
        print('Processed ${medicines.length} dispenser medicines');
        return medicines;
      }).handleError((error) {
        print('ERROR in dispenser medicines query for doctors: $error');
        return <MedicineSchedule>[];
      });

      // Query regular medicines collection (for liquids, injections, etc.)
      // No filtering or ordering to ensure all medicines are visible to doctors
      final medicineStream = medicineCollection
          .snapshots()
          .map((snapshot) {
        print('All regular medicines found: ${snapshot.docs.length}');
        final medicines = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          print(
              'Processing regular medicine: ${data['medicine']} for patient ${data['patientId']}');
          print('Full medicine data: $data');
          return MedicineScheduleModel.fromJson(data);
        }).toList();
        print('Processed ${medicines.length} regular medicines');
        return medicines;
      }).handleError((error) {
        print('ERROR in regular medicines query for doctors: $error');
        return <MedicineSchedule>[];
      });

      // Combine both streams
      return Rx.combineLatest2<List<MedicineSchedule>, List<MedicineSchedule>,
          List<MedicineSchedule>>(
        dispenserStream,
        medicineStream,
        (dispenserMeds, otherMeds) {
          final allMeds = [...dispenserMeds, ...otherMeds];
          print('Total medicines across all patients: ${allMeds.length}');
          // Print each medicine for debugging
          for (var med in allMeds) {
            print(
                'Combined medicine: ${med.medicine}, Type: ${med.type}, PatientId: ${med.patientId}');
          }
          return allMeds;
        },
      ).handleError((error) {
        print('Error in all medicines stream: $error');
        return <MedicineSchedule>[];
      });
    } catch (e) {
      print('Error getting all medicines stream: $e');
      return Stream.value([]);
    }
  }

  @override
  Future<Unit> addMedicineSchedule(MedicineSchedule dispenser) async {
    try {
      print('Processing medicine schedule with ID: ${dispenser.id}');
      print('User ID: ${dispenser.userId}');
      print('Patient ID: ${dispenser.patientId}');
      print('Medicine type: ${dispenser.type}');

      // Determine which collection to use based on medicine type
      final collection = (dispenser.type == MedicineType.capsule ||
              dispenser.type == MedicineType.tablet)
          ? dispenserMedicineCollection
          : medicineCollection;

      final model = MedicineScheduleModel(
        id: dispenser.id.isNotEmpty ? dispenser.id : collection.doc().id,
        index: dispenser.index,
        medicine: dispenser.medicine,
        type: dispenser.type,
        dose: dispenser.dose,
        schedule: ScheduleModel(
          days: dispenser.schedule.days,
          times: dispenser.schedule.times,
          weeksCount: dispenser.schedule.weeksCount,
          startDate: dispenser.schedule.startDate,
        ),
        userId: dispenser.userId,
        patientId: dispenser.patientId,
      );

      final data = model.toJson();
      print('Saving medicine with data: $data');

      if (dispenser.id.isNotEmpty) {
        // Update existing medicine
        print('Updating existing medicine with ID: ${dispenser.id}');
        await collection.doc(dispenser.id).set(data);
        print('Successfully updated existing medicine');
      } else {
        // Create new medicine
        print('Creating new medicine document');
        await collection.doc(model.id).set(data);
        print('Successfully created new medicine with ID: ${model.id}');
      }

      return unit;
    } catch (e) {
      print('Error processing medicine schedule: $e');
      throw ServerException(
          'Failed to process medicine schedule: ${e.toString()}');
    }
  }

  @override
  Future<Unit> deleteMedicineSchedule(String id) async {
    try {
      // Try to delete from both collections since we don't know which one contains the medicine
      await Future.wait([
        dispenserMedicineCollection.doc(id).delete(),
        medicineCollection.doc(id).delete(),
      ]);
      return unit;
    } catch (e) {
      throw ServerException('Failed to delete medicine schedule');
    }
  }
}
