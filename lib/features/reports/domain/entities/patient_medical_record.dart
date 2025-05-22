import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PatientMedicalRecord extends Equatable {
  final String? id;
  final String patientId;
  final String patientName;
  final int age;
  final String gender;
  final String primaryDiagnosis;
  final List<String> secondaryDiagnoses;
  final String allergies;
  final double weight; // in kg
  final double height; // in cm
  final String bloodType;
  final String emergencyContact;
  final DateTime lastUpdated;
  final String updatedBy;
  final Map<String, dynamic> additionalInfo;

  const PatientMedicalRecord({
    this.id,
    required this.patientId,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.primaryDiagnosis,
    this.secondaryDiagnoses = const [],
    this.allergies = '',
    required this.weight,
    required this.height,
    this.bloodType = '',
    this.emergencyContact = '',
    required this.lastUpdated,
    required this.updatedBy,
    this.additionalInfo = const {},
  });

  PatientMedicalRecord copyWith({
    String? id,
    String? patientId,
    String? patientName,
    int? age,
    String? gender,
    String? primaryDiagnosis,
    List<String>? secondaryDiagnoses,
    String? allergies,
    double? weight,
    double? height,
    String? bloodType,
    String? emergencyContact,
    DateTime? lastUpdated,
    String? updatedBy,
    Map<String, dynamic>? additionalInfo,
  }) {
    return PatientMedicalRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      primaryDiagnosis: primaryDiagnosis ?? this.primaryDiagnosis,
      secondaryDiagnoses: secondaryDiagnoses ?? this.secondaryDiagnoses,
      allergies: allergies ?? this.allergies,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodType: bloodType ?? this.bloodType,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // Convert from Firestore
  factory PatientMedicalRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PatientMedicalRecord(
      id: doc.id,
      patientId: data['patientId'] as String,
      patientName: data['patientName'] as String,
      age: data['age'] as int,
      gender: data['gender'] as String,
      primaryDiagnosis: data['primaryDiagnosis'] as String,
      secondaryDiagnoses: List<String>.from(data['secondaryDiagnoses'] ?? []),
      allergies: data['allergies'] as String? ?? '',
      weight: (data['weight'] as num).toDouble(),
      height: (data['height'] as num).toDouble(),
      bloodType: data['bloodType'] as String? ?? '',
      emergencyContact: data['emergencyContact'] as String? ?? '',
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      updatedBy: data['updatedBy'] as String,
      additionalInfo: data['additionalInfo'] as Map<String, dynamic>? ?? {},
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'age': age,
      'gender': gender,
      'primaryDiagnosis': primaryDiagnosis,
      'secondaryDiagnoses': secondaryDiagnoses,
      'allergies': allergies,
      'weight': weight,
      'height': height,
      'bloodType': bloodType,
      'emergencyContact': emergencyContact,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'updatedBy': updatedBy,
      'additionalInfo': additionalInfo,
    };
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        age,
        gender,
        primaryDiagnosis,
        secondaryDiagnoses,
        allergies,
        weight,
        height,
        bloodType,
        emergencyContact,
        lastUpdated,
        updatedBy,
        additionalInfo,
      ];
}
