import 'package:equatable/equatable.dart';
import 'package:mama_pill/core/utils/enums.dart';

class UserProfile extends Equatable {
  const UserProfile({
    this.id,
    this.email,
    this.password,
    this.username,
    this.role = UserRole.patient,
    this.patientId,
  });
  final String? id;
  final String? email;
  final String? password;
  final String? username;
  final UserRole role;
  final String? patientId;

  const UserProfile.empty()
      : id = '',
        username = '',
        password = '',
        email = '',
        patientId = '',
        role = UserRole.patient;

  @override
  List<Object?> get props => [
        id,
        email,
        password,
        username,
        role,
        patientId,
      ];
}
