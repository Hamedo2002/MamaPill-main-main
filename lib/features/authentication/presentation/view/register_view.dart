import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/messages.dart';
import 'package:mama_pill/core/resources/routes.dart';
import 'package:mama_pill/core/services/service_locator.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/core/utils/snack_bar_utils.dart';
import 'package:mama_pill/features/authentication/presentation/controller/sign_up/cubit/sign_up_cubit.dart';
import 'package:mama_pill/features/authentication/presentation/widgets/register_form.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SignUpCubit>(),

      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.backgroundSecondary,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: BlocConsumer<SignUpCubit, SignUpState>(
                      listener: (context, state) {
                        if (state.status == AuthStatus.failure) {
                          SnackBarUtils.showErrorSnackBar(context,
                              AppMessages.regiserationFailed, state.message);
                        } else if (state.status == AuthStatus.success) {
                          context.goNamed(AppRoutes.home.name);
                        }
                      },
                      builder: (context, state) {
                        final cubit = context.read<SignUpCubit>();
                        return RegisterForm(cubit: cubit, state: state);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
