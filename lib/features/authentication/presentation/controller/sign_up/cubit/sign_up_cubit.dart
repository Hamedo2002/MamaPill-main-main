import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/domain/entities/user_profile.dart';
import 'package:mama_pill/features/authentication/domain/usecases/sign_up_usecase.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this.signUpUseCase)
      : super(const SignUpState(selectedRole: null));

  final SignUpUseCase signUpUseCase;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController doctorIdController = TextEditingController();
  final TextEditingController patientIdController = TextEditingController();

  bool _isClosed = false;

  UserRole? get selectedRole => state.selectedRole;

  void updateRole(UserRole role) {
    if (_isClosed) return;
    emit(state.copyWith(
      selectedRole: role,
      status: AuthStatus.initial,
      message: '',
    ));
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> signUp() async {
    if (_isClosed) return;

    // Check role selection first
    if (selectedRole == null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        message: 'Please select your role',
      ));
      return;
    }

    formKey.currentState!.save();
    if (formKey.currentState!.validate()) {
      if (state.status == AuthStatus.submiting) return;
      try {
        emit(state.copyWith(status: AuthStatus.submiting));

        // Add delay to show loading screen
        await Future.delayed(const Duration(milliseconds: 500));

        // Get patient ID if role is patient
        final String? patientId = state.selectedRole == UserRole.patient
            ? patientIdController.text
            : null;

        print('Sign up details:');
        print('- Role: ${state.selectedRole?.name}');
        print('- Patient ID: $patientId');

        // Proceed with signup
        final result = await signUpUseCase(
          UserProfile(
            email: emailController.text,
            password: passwordController.text,
            username: usernameController.text,
            role: state.selectedRole!,
            patientId: patientId,
          ),
        );

        if (_isClosed) return;

        result.fold(
          (failure) => emit(state.copyWith(
              status: AuthStatus.failure, message: failure.message)),
          (user) => emit(state.copyWith(status: AuthStatus.success)),
        );
      } catch (e) {
        if (_isClosed) return;
        emit(state.copyWith(
            status: AuthStatus.failure, message: 'An error occurred'));
      }
    }
  }

  void togglePasswordVisibility() {
    if (_isClosed) return;
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  @override
  Future<void> close() {
    _isClosed = true;
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    doctorIdController.dispose();
    patientIdController.dispose();
    return super.close();
  }
}
