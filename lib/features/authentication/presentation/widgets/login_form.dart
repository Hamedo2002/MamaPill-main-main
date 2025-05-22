import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mama_pill/core/presentation/widgets/custom_button.dart';
import 'package:mama_pill/core/presentation/widgets/custom_progress_indicator.dart';
import 'package:mama_pill/core/presentation/widgets/custom_input_field.dart';
import 'package:mama_pill/core/helpers/validator.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/routes.dart';
import 'package:mama_pill/core/resources/strings.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/presentation/controller/login/cubit/login_cubit.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.cubit,
    required this.state,
  });

  final LoginCubit cubit;
  final LoginState state;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      // Reduce animation duration for faster response
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        // Use faster curve
        curve: const Interval(0.0, 0.7, curve: Curves.fastOutSlowIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      // Reduce slide distance for faster animation
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        // Use faster curve
        curve: Curves.fastOutSlowIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Form(
          key: widget.cubit.formKey,
          child: Container(
            margin: AppMargin.largeH.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _loginHeaderTitle(textTheme),
                SizedBox(height: AppHeight.h40.h),
                _emailTextField(widget.cubit),
                SizedBox(height: AppHeight.h16.h),
                _passwordTextField(widget.cubit, widget.state),
                _forgetPasswordButton(textTheme),
                SizedBox(height: AppHeight.h48.h),
                widget.state.status == AuthStatus.submiting
                    ? const Center(child: CustomProgressIndicator())
                    : _loginButton(widget.cubit),
                SizedBox(height: AppHeight.h16.h),
                _registerNow(context, textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  CustomButton _loginButton(LoginCubit cubit) {
    return CustomButton(
      onTap: () {
        if (cubit.formKey.currentState!.validate()) {
          cubit.login();
        }
      },
      label: AppStrings.login,
      backgroundColor: AppColors.primary,
      margin: AppMargin.mediumH.w,
    );
  }

  CustomInputField _passwordTextField(LoginCubit cubit, LoginState state) {
    return CustomInputField(
      hint: AppStrings.passwordHint,
      obscureText: true,
      prefixIcon: Icons.lock,
      controller: cubit.passwordController,
      validator: (value) => Validator.validatePassword(value!),
      isPasswordVisible: state.isPasswordVisible,
      toggelPasswordVisibility: () => cubit.togglePasswordVisibility(),
    );
  }

  CustomInputField _emailTextField(LoginCubit cubit) {
    return CustomInputField(
      hint: AppStrings.emailHint,
      prefixIcon: Icons.email,
      controller: cubit.emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) => Validator.validateEmail(value!),
    );
  }

  Column _loginHeaderTitle(TextTheme textTheme) {
    return Column(
      children: [
        Text(
          AppStrings.loginTitle,
          style: textTheme.titleLarge?.copyWith(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: AppColors.primary.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        SizedBox(height: AppHeight.h6.h),
        Text(
          AppStrings.loginDescription,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 16.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Row _forgetPasswordButton(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {},
          child: Text(
            AppStrings.forgotPassword,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }

  Row _registerNow(BuildContext context, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.notMemberYet,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
          ),
        ),
        TextButton(
          onPressed: () => context.pushNamed(AppRoutes.register.name),
          child: Text(
            AppStrings.registerNow,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}
