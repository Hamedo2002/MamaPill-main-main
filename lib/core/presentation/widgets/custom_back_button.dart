import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back_ios,
        size: AppSize.s20,
        color: AppColors.primary,
      ),
      onPressed: onPressed ?? () => context.pop(),
    );
  }
}
