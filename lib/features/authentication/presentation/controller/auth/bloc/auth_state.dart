part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = AppStatus.initial,
    this.user = const UserProfile.empty(),
    this.errorMessage,
  });

  final AppStatus status;
  final UserProfile user;
  final String? errorMessage;

  AuthState copyWith({
    AppStatus? status,
    UserProfile? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
