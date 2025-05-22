import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/resources/values.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.width,
    this.height,
    this.textColor,
    this.margin,
    this.isLoading = false,
  });
  final String label;
  final Function() onTap;
  final Color? textColor;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // Use RepaintBoundary to isolate button animations for better performance
    return RepaintBoundary(
      child: Container(
        margin: margin,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            // Remove animations that might cause jank
            elevation: 0,
            shadowColor: Colors.transparent,
            // Use InkRipple for faster ripple effect
            splashFactory: InkRipple.splashFactory,
            backgroundColor: backgroundColor,
            // Use const where possible to avoid rebuilds
            minimumSize: Size(width ?? AppWidth.screenWidth, height ?? AppHeight.h48.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11.r),
            ),
            // Add tapTargetSize for faster touch response
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            // Optimize animation duration
            animationDuration: const Duration(milliseconds: 100),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: CircularProgressIndicator(
                    color: textColor ?? Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(color: textColor),
                  // Avoid text measurement during animation
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
