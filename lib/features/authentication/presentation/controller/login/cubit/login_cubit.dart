import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/domain/entities/user_profile.dart';
import 'package:mama_pill/features/authentication/domain/usecases/login_usecase.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.loginUseCase) : super(const LoginState());

  final LoginUseCase loginUseCase;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (state.status == AuthStatus.submiting) return;
    try {
      emit(state.copyWith(status: AuthStatus.submiting));
      
      // Add delay to show loading screen
      await Future.delayed(const Duration(milliseconds: 500));
      
      final result = await loginUseCase(
        UserProfile(
          email: emailController.text,
          password: passwordController.text,
        ),
      );
      result.fold(
        (failure) => emit(
            state.copyWith(status: AuthStatus.failure, message: failure.message)),
        (user) => emit(state.copyWith(status: AuthStatus.success)),
      );
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.failure, message: 'An error occurred'));
    }
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }
}
