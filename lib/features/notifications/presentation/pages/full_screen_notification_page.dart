import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/presentation/widgets/custom_button.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';

class FullScreenNotificationPage extends StatelessWidget {
  final String medicineName;
  final String dosage;

  const FullScreenNotificationPage({
    Key? key, 
    required this.medicineName, 
    required this.dosage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: AppWidth.w48.w,
                height: AppHeight.h4.h,
                margin: const EdgeInsets.only(top: 14).w,
                decoration: BoxDecoration(
                  color: AppColors.divider.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10).r,
                ),
              ),
            ),

            SizedBox(height: 30.h),

            // Medicine Icon
            Icon(
              Icons.medication_rounded, 
              size: 100.sp, 
              color: AppColors.primary,
            ),
            
            SizedBox(height: 20.h),
            
            // Medicine Name
            Text(
              'Time to Take',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 10.h),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                medicineName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            
            SizedBox(height: 10.h),
            
            // Dosage
            Text(
              'Dosage: $dosage',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.7),
                fontSize: 20.sp,
              ),
            ),
            
            SizedBox(height: 50.h),
            
            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: CustomButton(
                label: 'Dismiss',
                onTap: () => Navigator.of(context).pop(),
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
