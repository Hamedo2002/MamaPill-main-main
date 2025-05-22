import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/resources/colors.dart';

class MedicineTextField extends StatelessWidget {
  const MedicineTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textAlign = TextAlign.start,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return TextField(
      controller: controller,
      style: textTheme.bodyMedium?.copyWith(
        fontSize: 16.sp,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      textAlign: textAlign,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        fillColor: Colors.transparent,
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: textTheme.bodySmall?.copyWith(
          fontSize: 16.sp,
          color: AppColors.textSecondary.withOpacity(0.7),
        ),
      ),
    );
  }
}
