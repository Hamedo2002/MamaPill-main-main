import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/utils/bottom_sheet_utils.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/medicine/presentation/widgets/medicine_form.dart';
import 'package:mama_pill/features/calendar/presentation/controller/cubit/calendar_cubit.dart';

class AddMedicineTile extends StatelessWidget {
  const AddMedicineTile({
    super.key,
    required this.patientId,
    required this.index,
  });
  
  final String patientId;
  final int index;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isDoctor = authState.user.role == UserRole.doctor;
    
    // Debug logging
    print('AddMedicineTile - Auth state: $authState');
    print('AddMedicineTile - User role: ${authState.user.role.name}');
    print('AddMedicineTile - Is doctor: $isDoctor');
    
    // Only doctors can add medicines
    if (!isDoctor) {
      print('AddMedicineTile - Not showing add button because user is not a doctor');
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: () async {
        await BottomSheetUtils.showButtomSheet(
          context,
          MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: context.read<AuthBloc>(),
              ),
              BlocProvider.value(
                value: context.read<CalendarCubit>(),
              ),
            ],
            child: MedicineForm(
              patientId: patientId,
              index: index,
              onSuccess: () {
                // Navigation is handled in the form
              },
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: 10.w),
        width: 120.w,
        height: 210.h, // Match the height of medicine tiles
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.primary.withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add more space at the top
            SizedBox(height: 10.h),
            
            // Plus icon
            Icon(Icons.add, color: AppColors.primary, size: 40.h),
            
            SizedBox(height: 10.h),
            
            // Text
            Text(
              'Add',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            // Add more space at the bottom
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
