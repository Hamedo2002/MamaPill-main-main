import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/presentation/widgets/medicine_icon_card.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/core/utils/bottom_sheet_utils.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/core/utils/extensions.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/presentation/widgets/edit_medicine_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_schedule/bloc/medicine_schedule_bloc.dart';

class MedicineScheduleTile extends StatelessWidget {
  bool _shouldShowCheckmark(MedicineSchedule medicine) {
    final now = DateTime.now();

    // Check if today is a scheduled day
    if (!medicine.schedule.days.contains(now.weekday)) {
      return false;
    }

    // Check if any scheduled time has passed
    for (final scheduledTime in medicine.schedule.times) {
      final parts = scheduledTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].split(' ')[0]); // Remove AM/PM
      final isPM = scheduledTime.toLowerCase().contains('pm');

      final scheduleHour = isPM && hour != 12 ? hour + 12 : hour;
      final scheduleDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        scheduleHour,
        minute,
      );

      // If the scheduled time has passed, show checkmark
      if (now.isAfter(scheduleDateTime)) {
        return true;
      }
    }
    return false;
  }

  const MedicineScheduleTile({super.key, required this.medicineSchedule});
  final MedicineSchedule medicineSchedule;

  @override
  Widget build(BuildContext context) {
    final String intake =
        '${medicineSchedule.dose * medicineSchedule.schedule.times.length * medicineSchedule.schedule.days.length}';

    // Get current user role
    final authState = context.read<AuthBloc>().state;
    final isDoctor = authState.user.role == UserRole.doctor;

    return _buildContent(context, intake, isDoctor);
  }

  Widget _buildContent(BuildContext context, String intake, bool isDoctor) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 16.sp,
    );

    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      height: 1.3,
    );

    final timeStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.black54,
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
    );

    // Use a single container with direct Column child
    return Container(
      width: 130.w,
      height: 220.h, // Increased height to accommodate content
      margin: EdgeInsets.only(right: 10.w),
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 12.h,
      ), // Reduced vertical padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: medicineSchedule.type.color.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Added to prevent overflow
        children: [
          // Icon at the top with Taken indicator
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MedicineIconCard(type: medicineSchedule.type),
              if (_shouldShowCheckmark(medicineSchedule))
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 2.h,
                  ), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 12.sp, // Reduced icon size
                      ),
                      SizedBox(width: 2.w), // Reduced spacing
                      Text(
                        'Taken',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11.sp, // Reduced font size
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h), // Reduced spacing
          // Title section
          Text(
            medicineSchedule.medicine,
            style: titleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 3.h), // Reduced spacing
          // Subtitle section
          Text(
            '$intake ${medicineSchedule.type.shortName} over ${medicineSchedule.schedule.weeksCount} ${medicineSchedule.schedule.weeksCount == 1 ? 'week' : 'weeks'}',
            style: subtitleStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 3.h), // Reduced spacing
          // Time schedule
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule,
                size: 14.sp,
                color: Colors.black54,
              ), // Reduced icon size
              SizedBox(width: 3.w), // Reduced spacing
              Expanded(
                child: Text(
                  medicineSchedule.schedule.times
                      .map((time) {
                        final parts = time.split(' ');
                        if (parts.length == 2) {
                          return '${parts[0]} ${parts[1].toUpperCase()}';
                        }
                        return time;
                      })
                      .join(' '),
                  style: timeStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          Spacer(),

          SizedBox(height: 6.h), // Reduced spacing
          // Only show edit/delete buttons for doctors
          if (isDoctor)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Edit button
                Container(
                  decoration: BoxDecoration(
                    color: medicineSchedule.type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8.r),
                      onTap:
                          () => BottomSheetUtils.showButtomSheet(
                            context,
                            EditDispenserForm(
                              medicine: medicineSchedule,
                              index: medicineSchedule.index,
                            ),
                          ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: medicineSchedule.type.color,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Edit',
                              style: TextStyle(
                                color: medicineSchedule.type.color,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Delete button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8.r),
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder:
                              (ctx) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                                backgroundColor: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 24,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.delete_forever,
                                        color: Colors.red,
                                        size: 48,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Delete Medicine?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Are you sure you want to delete this medicine?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed:
                                                  () => Navigator.of(ctx).pop(),
                                              style: OutlinedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                                final medicineScheduleBloc =
                                                    BlocProvider.of<
                                                      MedicineScheduleBloc
                                                    >(context);
                                                medicineScheduleBloc.add(
                                                  MedicineScheduleDeleted(
                                                    medicineId:
                                                        medicineSchedule.id,
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text('Delete'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 4.h,
                        ),
                        child: Icon(
                          Icons.delete_outlined,
                          color: Colors.red,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          // Empty placeholder if not doctor
          if (!isDoctor) Container(),
        ],
      ),
    );
  }
}

class CardTileFooter extends StatelessWidget {
  const CardTileFooter({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 14.w).w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(100).w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: AppPadding.smallH,
                  child: Text(
                    'Edit',
                    style: textTheme.titleSmall!.copyWith(
                      fontSize: AppFontSize.f12.sp,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
