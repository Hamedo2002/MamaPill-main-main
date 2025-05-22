import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/presentation/widgets/medicine_icon_card.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/core/utils/bottom_sheet_utils.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/core/utils/extensions.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/domain/entities/schedule.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_schedule/bloc/medicine_schedule_bloc.dart';
import 'package:mama_pill/features/medicine/presentation/widgets/edit_medicine_form.dart';

class MedicineTile extends StatelessWidget {
  const MedicineTile({
    super.key,
    required this.medicine,
  });
  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    // Get current user role
    final authState = context.read<AuthBloc>().state;
    final isDoctor = authState.user.role == UserRole.doctor;
    
    // Create a medicine schedule object for editing
    // We need to create a Schedule object since Medicine doesn't have schedule property
    final medicineSchedule = MedicineSchedule(
      id: medicine.id,
      medicine: medicine.name,
      type: medicine.type,
      dose: medicine.dose,
      // Create a default schedule with the medicine's time
      schedule: Schedule(
        days: [DateTime.now().weekday], // Default to today
        times: [medicine.time],
        weeksCount: 1,
      ),
      index: 0, // Default index
      userId: authState.user.id ?? '', // Current user ID with null safety
      patientId: authState.user.id ?? '', // Default to current user with null safety
    );

    // Use a fixed height container instead of relying on CustomCardTile's layout
    return Container(
      width: 130.w, // Increased width to match MedicineScheduleTile
      height: 170.h, // Reduced height to prevent overflow
      margin: EdgeInsets.only(right: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: medicine.type.color.withOpacity(0.1),
      ),
      padding: EdgeInsets.all(12.w),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon at the top
              MedicineIconCard(type: medicine.type),
              SizedBox(height: 8.h),
              
              // Title
              Text(
                medicine.name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Subtitle
              Text(
                '${medicine.dose} ${medicine.type.name}',
                style: TextStyle(
                  fontSize: 15.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Push footer to bottom
              Spacer(),
              
              // Footer
              MedicineTileFooter(color: medicine.type.color, time: medicine.time),
            ],
          ),
          
          // Only show edit/delete options for doctors
          if (isDoctor)
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit button
                  InkWell(
                    onTap: () {
                      BottomSheetUtils.showButtomSheet(
                        context,
                        EditDispenserForm(
                          medicine: medicineSchedule,
                          index: 0,
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 16.w,
                        color: medicine.type.color,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  // Delete button
                  InkWell(
                    onTap: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Medicine'),
                          content: Text('Are you sure you want to delete ${medicine.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Delete the medicine
                                final medicineBloc = context.read<MedicineScheduleBloc>();
                                medicineBloc.add(
                                  MedicineScheduleDeleted(
                                    medicineId: medicine.id,
                                  ),
                                );
                              },
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete,
                        size: 16.w,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class MedicineTileFooter extends StatelessWidget {
  const MedicineTileFooter({
    super.key,
    required this.color,
    required this.time,
  });
  final Color color;
  final String time;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle titleTextStyle = textTheme.titleSmall!.copyWith(
      color: AppColors.white,
      fontSize: AppFontSize.f13.sp,
    );
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12).w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(100).w,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(time, style: titleTextStyle),
            Icon(Icons.alarm, size: 14.h, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
