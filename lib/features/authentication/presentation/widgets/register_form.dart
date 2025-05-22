import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mama_pill/core/helpers/validator.dart';
import 'package:mama_pill/core/presentation/widgets/custom_button.dart';
import 'package:mama_pill/core/presentation/widgets/custom_progress_indicator.dart';
import 'package:mama_pill/core/presentation/widgets/custom_input_field.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/routes.dart';
import 'package:mama_pill/core/resources/strings.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/presentation/controller/sign_up/cubit/sign_up_cubit.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, required this.cubit, required this.state});

  final SignUpCubit cubit;
  final SignUpState state;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

Widget _roleDropdown(BuildContext context, SignUpCubit cubit) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: AppPadding.p12.w),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRole>(
          value: cubit.selectedRole,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.textSecondary,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Select your role',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          items:
              [UserRole.patient, UserRole.doctor, UserRole.staff].map((
                UserRole role,
              ) {
                late final IconData icon;
                late final Color iconColor;

                switch (role) {
                  case UserRole.doctor:
                    icon = Icons.medical_information;
                    iconColor = Colors.blue; // Professional medical blue
                    break;
                  case UserRole.staff:
                    icon =
                        Icons.medical_information_rounded; // Healthcare staff
                    iconColor = Colors.teal; // Healthcare teal
                    break;
                  case UserRole.patient:
                    icon = Icons.personal_injury_rounded; // Patient care
                    iconColor = Colors.orange; // Warm, friendly color
                    break;
                }

                return DropdownMenuItem<UserRole>(
                  value: role,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: iconColor, size: 20),
                      SizedBox(width: 12),
                      Text(
                        role.name.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (UserRole? newValue) {
            cubit.updateRole(newValue ?? UserRole.patient);
          },
        ),
      ),
    ),
  );
}

Future<String?> _showIdDialog(BuildContext context, UserRole role) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(
            'Please enter your ${role.name} ID',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter ${role.name} ID',
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16.sp),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              ),
              child: Text(
                'Verify',
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            ),
          ],
        ),
  );
}

Widget _patientIdField(SignUpCubit cubit) {
  // Only show the enter code box for patients
  if (cubit.selectedRole != UserRole.patient) {
    return const SizedBox.shrink(); // Return empty widget if not patient
  }
  
  return Builder(
    builder: (context) => Column(
      children: [
        SizedBox(height: AppHeight.h16.h),
        ElevatedButton(
          onPressed: () async {
            final id = await _showIdDialog(
              context,
              UserRole.patient,
            );
            if (id != null) {
              cubit.patientIdController.text = id;
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          ),
          child: const Text('Enter Patient Code'),
        ),
      ],
    ),
  );
}

class _RegisterFormState extends State<RegisterForm>
    with SingleTickerProviderStateMixin {
  late SignUpCubit _cubit;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit;
    // Set initial role to patient
    _cubit.updateRole(UserRole.patient);

    _animationController = AnimationController(
      vsync: this,
      // Reduce animation duration for faster response
      duration: const Duration(milliseconds: 250),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn),
    );

    _slideAnimation = Tween<Offset>(
      // Reduce slide distance for faster animation
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.fastLinearToSlowEaseIn),
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
                SizedBox(height: AppHeight.h32.h),
                _usernameTextField(widget.cubit),
                SizedBox(height: AppHeight.h16.h),
                _emailTextField(widget.cubit),
                SizedBox(height: AppHeight.h16.h),
                _passwordTextField(widget.cubit, widget.state),
                SizedBox(height: AppHeight.h16.h),
                _confirmPasswordTextField(widget.cubit, widget.state),
                SizedBox(height: AppHeight.h16.h),
                _roleDropdown(context, widget.cubit),
                _patientIdField(widget.cubit),
                SizedBox(height: AppHeight.h48.h),
                widget.state.status == AuthStatus.submiting
                    ? const Center(child: CustomProgressIndicator())
                    : _loginButton(widget.cubit, context),
                SizedBox(height: AppHeight.h16.h),
                _loginNow(context, textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _loginButton(SignUpCubit cubit, BuildContext context) {
  return BlocBuilder<SignUpCubit, SignUpState>(
    builder: (context, state) {
      return CustomButton(
        isLoading: state.status == AuthStatus.submiting,
        onTap: () async {
          // First validate the form
          if (!cubit.formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please fill all fields correctly'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Validate username specifically
          final usernameError = Validator.validateUsername(
            cubit.usernameController.text,
          );
          if (usernameError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(usernameError),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Validate email specifically
          final emailError = Validator.validateEmail(
            cubit.emailController.text,
          );
          if (emailError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(emailError), backgroundColor: Colors.red),
            );
            return;
          }

          // Validate password specifically
          final passwordError = Validator.validatePassword(
            cubit.passwordController.text,
          );
          if (passwordError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(passwordError),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Validate confirm password
          final confirmPasswordError = Validator.validateConfirmPassword(
            cubit.confirmPasswordController.text,
            cubit.passwordController.text,
          );
          if (confirmPasswordError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(confirmPasswordError),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Validate role selection
          if (cubit.selectedRole == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select your role'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Validate patient ID for patient role
          if (cubit.selectedRole == UserRole.patient) {
            if (cubit.patientIdController.text.isEmpty ||
                cubit.patientIdController.text.length < 4) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please enter a valid patient ID (minimum 4 characters)',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            // For patients, sign up directly after all validations pass
            cubit.signUp();
            return;
          }

          // For doctor and staff roles, verify ID
          final String? verificationId = await showDialog<String>(
            context: context,
            barrierDismissible: false, // Prevent dismissing by tapping outside
            builder: (ctx) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  'Please enter your ${cubit.selectedRole?.name} ID',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                content: Container(
                  constraints: BoxConstraints(maxWidth: 300.w),
                  child: CustomInputField(
                    controller: cubit.doctorIdController,
                    hint: 'Enter ${cubit.selectedRole?.name} ID',
                    prefixIcon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ID is required';
                      }
                      if (value.length < 4) {
                        return 'ID must be at least 4 characters';
                      }
                      return null;
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final validId =
                          cubit.selectedRole == UserRole.doctor
                              ? '1112'
                              : '1113';
                      if (cubit.doctorIdController.text == validId) {
                        Navigator.pop(context, cubit.doctorIdController.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Invalid ${cubit.selectedRole?.name} ID',
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.all(10),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                    ),
                    child: Text(
                      'Verify',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          );

          if (verificationId == null) return; // User cancelled
          cubit.signUp();
        },
        label: AppStrings.signUp,
        backgroundColor: AppColors.primary,
        margin: AppMargin.mediumH.w,
      );
    },
  );
}

CustomInputField _passwordTextField(SignUpCubit cubit, SignUpState state) {
  return CustomInputField(
    obscureText: true,
    hint: AppStrings.passwordHint,
    prefixIcon: Icons.lock,
    controller: cubit.passwordController,
    isPasswordVisible: state.isPasswordVisible,
    validator: (value) => Validator.validatePassword(value!),
    toggelPasswordVisibility: () => cubit.togglePasswordVisibility(),
  );
}

CustomInputField _confirmPasswordTextField(
  SignUpCubit cubit,
  SignUpState state,
) {
  return CustomInputField(
    obscureText: true,
    prefixIcon: Icons.lock,
    hint: AppStrings.confirmPasswordHint,
    controller: cubit.confirmPasswordController,
    isPasswordVisible: state.isPasswordVisible,
    validator:
        (value) => Validator.validateConfirmPassword(
          value!,
          cubit.passwordController.text,
        ),
    toggelPasswordVisibility: () => cubit.togglePasswordVisibility(),
  );
}

CustomInputField _emailTextField(SignUpCubit cubit) {
  return CustomInputField(
    hint: AppStrings.emailHint,
    prefixIcon: Icons.email_rounded,
    controller: cubit.emailController,
    keyboardType: TextInputType.emailAddress,
    validator: (value) => Validator.validateEmail(value!),
  );
}

CustomInputField _usernameTextField(SignUpCubit cubit) {
  return CustomInputField(
    hint: AppStrings.usernameHint,
    prefixIcon: Icons.person,
    controller: cubit.usernameController,
    textCapitalization: TextCapitalization.words,
    keyboardType: TextInputType.emailAddress,
    validator: (value) => Validator.validateField(value!),
  );
}

Column _loginHeaderTitle(TextTheme textTheme) {
  return Column(
    children: [
      SizedBox(height: 16.h),
      Text(
        AppStrings.registerTitle,
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
      SizedBox(height: AppHeight.h12.h),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Text(
          AppStrings.registerDescription,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 16.sp,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(height: 20.h),
    ],
  );
}

Row _loginNow(BuildContext context, TextTheme textTheme) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        AppStrings.alreadyHaveAcc,
        style: textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
        ),
      ),
      TextButton(
        onPressed: () => context.pushNamed(AppRoutes.login.name),
        child: Text(
          AppStrings.loginNow,
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
