import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';

class SnackBarUtils {
  static void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(AppWidth.w16.w),
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showErrorSnackBar(
      BuildContext context, String errorTitle, String errorMessage) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.up,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.medium),
      elevation: 0,
      backgroundColor: AppColors.backgroundPrimary,
      margin: EdgeInsets.all(AppWidth.w16.w),
      content: SizedBox(
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            SizedBox(width: AppWidth.w16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    errorTitle,
                    style: textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: AppHeight.h2.h),
                  Text(
                    errorMessage,
                    style: textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
