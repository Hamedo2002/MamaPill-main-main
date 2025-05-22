import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';

class CustomCardTile extends StatelessWidget {
  const CustomCardTile({
    required this.title,
    required this.subtitle,
    super.key,
    this.icon,
    this.footer,
    this.color,
    this.width,
    this.height,
    this.onTap,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });
  final Widget title;
  final Widget subtitle;
  final Widget? icon;
  final Widget? footer;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry contentPadding;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle subtitleStyle =
        textTheme.titleSmall!.copyWith(fontSize: AppFontSize.f15.sp);
    TextStyle titleStyle = textTheme.titleMedium!.copyWith(
      fontSize: AppFontSize.f16.sp,
      fontWeight: FontWeight.w600,
    );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? AppWidth.w120.w,
        height: height,
        margin: const EdgeInsets.only(right: 10).w,
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.small.w,
          color: color ?? AppColors.primary.withOpacity(0.1),
        ),
        child: Container(
          padding: contentPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Important to prevent overflow
            children: [
              icon ?? const SizedBox.shrink(),
              SizedBox(height: 8.h),
              DefaultTextStyle(
                style: titleStyle,
                child: title,
              ),
              SizedBox(height: 4.h),
              DefaultTextStyle(
                style: subtitleStyle,
                child: subtitle,
              ),
              const Spacer(), // Use a single Spacer to push footer to bottom
              footer ?? const SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
