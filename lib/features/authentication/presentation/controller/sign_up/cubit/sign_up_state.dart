part of 'sign_up_cubit.dart';

class SignUpState extends Equatable {
  const SignUpState({
    this.status = AuthStatus.initial,
    this.isPasswordVisible = true,
    this.message = '',
    this.selectedRole,
  });
  final AuthStatus status;
  final bool isPasswordVisible;
  final String message;
  final UserRole? selectedRole;

  SignUpState copyWith({
    AuthStatus? status,
    bool? isPasswordVisible,
    String? message,
    UserRole? selectedRole,
  }) {
    return SignUpState(
      status: status ?? this.status,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      message: message ?? this.message,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }

  @override
  List<Object?> get props => [status, isPasswordVisible, message, selectedRole];
}
