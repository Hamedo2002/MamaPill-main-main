import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/resources/colors.dart';

class CustomInputField extends StatefulWidget {
  const CustomInputField({
    Key? key,
    required this.controller,
    this.hint,
    this.label,
    this.validator,
    this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.isPasswordVisible = false,
    this.toggelPasswordVisibility,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);
  final String? hint;
  final String? label;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool isPasswordVisible;
  final TextCapitalization textCapitalization;
  final void Function()? toggelPasswordVisibility;

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
            child: Text(
              '${widget.label}',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.textPrimary.withOpacity(0.7),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade50,
            border: Border.all(
              color: hasError ? Colors.red : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            validator: (value) {
              final error = widget.validator?.call(value);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  hasError = error != null;
                });
              });
              return null;
            },
            obscureText: widget.isPasswordVisible,
            style: textTheme.bodyMedium!.copyWith(
              color: AppColors.textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: AppColors.textPrimary.withOpacity(0.4),
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              errorStyle: const TextStyle(height: 0),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: EdgeInsets.only(left: 12.w, right: 8.w),
                      child: Icon(
                        widget.prefixIcon,
                        size: 20.h,
                        color: AppColors.textPrimary.withOpacity(0.5),
                      ),
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Visibility(
                        visible: widget.isPasswordVisible,
                        replacement: const Icon(Icons.visibility_off),
                        child: const Icon(Icons.visibility),
                      ),
                      color: widget.isPasswordVisible
                          ? AppColors.primary
                          : AppColors.disabled,
                      onPressed: widget.toggelPasswordVisibility,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
