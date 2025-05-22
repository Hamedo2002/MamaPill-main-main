import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mama_pill/core/presentation/widgets/custom_button.dart';
import 'package:mama_pill/core/presentation/widgets/custom_input_card.dart';
import 'package:mama_pill/core/presentation/widgets/custom_input_field.dart';
import 'package:mama_pill/core/presentation/widgets/custom_progress_indicator.dart';
import 'package:mama_pill/core/presentation/widgets/day_time_card_tile.dart';
import 'package:mama_pill/core/presentation/widgets/day_time_list.dart';
import 'package:mama_pill/core/presentation/widgets/medicine_text_field.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/messages.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/core/services/service_locator.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/core/utils/extensions.dart';
import 'package:mama_pill/core/utils/top_notification_utils.dart';
import 'package:mama_pill/core/helpers/validator.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/domain/entities/schedule.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_form/cubit/medicine_form_cubit.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_schedule/bloc/medicine_schedule_bloc.dart';
import 'package:mama_pill/features/notifications/domain/entities/notification.dart';
import 'package:mama_pill/features/notifications/presentation/controller/bloc/notification_bloc.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mama_pill/features/calendar/presentation/controller/cubit/calendar_cubit.dart';

class MedicineForm extends StatelessWidget {
  const MedicineForm({
    super.key,
    required this.patientId,
    required this.index,
    this.onSuccess,
    this.existingMedicine, // Add this parameter
  });
  final String patientId;
  final int index;
  final VoidCallback? onSuccess;
  final MedicineSchedule? existingMedicine; // Add this field

  @override
  Widget build(BuildContext context) {
    // Get current user role
    final authState = context.read<AuthBloc>().state;
    final isDoctor = authState.user.role == UserRole.doctor;

    // Only doctors can add/edit medicines
    if (!isDoctor) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only doctors can add or edit medicines'),
          backgroundColor: Colors.red,
        ),
      );
      return const SizedBox.shrink();
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = sl<MedicineFormCubit>();
            if (existingMedicine != null) {
              cubit.medicineNameController.text = existingMedicine!.medicine;
              while (cubit.state.dose < existingMedicine!.dose) {
                cubit.incrementDose();
              }
              while (cubit.state.type != existingMedicine!.type) {
                cubit.toggleMedicineType();
              }
              for (var day in existingMedicine!.schedule.days) {
                cubit.toggleDaySelection(day);
              }
              for (var time in existingMedicine!.schedule.times) {
                cubit.addTime(time);
              }
              while (cubit.state.weeksCount <
                  existingMedicine!.schedule.weeksCount) {
                cubit.incrementWeeksCount();
              }
            }
            return cubit;
          },
        ),
        BlocProvider(create: (context) => sl<MedicineScheduleBloc>()),
        BlocProvider(create: (context) => sl<NotificationBloc>()),
        BlocProvider(create: (context) => sl<CalendarCubit>()),
      ],
      child: BlocListener<MedicineScheduleBloc, MedicineScheduleState>(
        listener: (context, state) {
          if (state.saveStatus == RequestStatus.success) {
            TopNotificationUtils.showSuccessNotification(
              context,
              title: 'Success',
              message: 'Medicine added successfully',
            );

            try {
              context.read<CalendarCubit>().changeSelectedDate(DateTime.now());
            } catch (e) {
              // If not found, do nothing
            }

            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            });
          } else if (state.saveStatus == RequestStatus.failure) {
            TopNotificationUtils.showErrorNotification(
              context,
              title: 'Error',
              message: state.message,
            );
          }
        },
        child: BlocBuilder<MedicineFormCubit, MedicineFormState>(
          builder: (context, medicineFormState) {
            final MedicineFormCubit medicineFormCubit =
                context.read<MedicineFormCubit>();
            return BlocBuilder<MedicineScheduleBloc, MedicineScheduleState>(
              builder: (context, medicineScheduleState) {
                return Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _dragLable(),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildHeader(context, medicineFormCubit),
                                    SizedBox(height: 24.h),
                                    _medicineNameTextField(context),
                                    SizedBox(height: 16.h),
                                    _doseCounter(context),
                                    SizedBox(height: 16.h),
                                    _weeksCounter(context),
                                    SizedBox(height: 16.h),
                                    _weekdaysWidget(context),
                                    SizedBox(height: 16.h),
                                    _timeIntervalsWidget(
                                      context,
                                      medicineFormCubit,
                                      medicineFormState,
                                    ),
                                    SizedBox(height: 100.h),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _buildBottomButton(
                            context,
                            medicineScheduleState,
                            medicineFormCubit,
                            medicineFormState,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MedicineFormCubit cubit) {
    final theme = Theme.of(context);
    final medicineTypeColor = cubit.state.type.color;
    final medicineTypeIcon = cubit.state.type.icon;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: medicineTypeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: medicineTypeColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: ImageIcon(
                AssetImage(medicineTypeIcon),
                size: 24.sp,
                color: medicineTypeColor,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existingMedicine != null
                      ? 'Edit Medicine'
                      : 'Add New Medicine',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: medicineTypeColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Fill in the details below',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    MedicineScheduleState medicineScheduleState,
    MedicineFormCubit medicineFormCubit,
    MedicineFormState medicineFormState,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48.h,
          child:
              medicineScheduleState.saveStatus == RequestStatus.loading
                  ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                    onPressed: null,
                    child: SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                    onPressed:
                        () => _handleSave(
                          context,
                          medicineFormCubit,
                          medicineFormState,
                        ),
                    child: Text(
                      existingMedicine != null
                          ? 'Update Medicine'
                          : 'Add Medicine',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    MedicineFormCubit medicineFormCubit,
    MedicineFormState medicineFormState,
  ) async {
    // Validate input
    if (medicineFormCubit.medicineNameController.text.isEmpty) {
      TopNotificationUtils.showErrorNotification(
        context,
        title: 'Validation Error',
        message: 'Please enter a medicine name',
      );
      return;
    }

    if (medicineFormState.selectedDays.isEmpty) {
      TopNotificationUtils.showErrorNotification(
        context,
        title: 'Validation Error',
        message: 'Please select at least one day',
      );
      return;
    }

    if (medicineFormState.selectedTimes.isEmpty) {
      TopNotificationUtils.showErrorNotification(
        context,
        title: 'Validation Error',
        message: 'Please select at least one time',
      );
      return;
    }

    // Get current user role and ID
    final authState = context.read<AuthBloc>().state;
    print(
      'Adding medicine schedule as user with role: ${authState.user.role.name}',
    );
    print('Current user ID: ${authState.user.id}');

    // Show patient ID dialog for doctors
    String? actualPatientId = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final patientIdController = TextEditingController(text: patientId);
        return AlertDialog(
          title: Text('Enter Patient ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please enter the patient ID for this medicine:'),
              SizedBox(height: 16),
              CustomInputField(
                controller: patientIdController,
                hint: 'Patient ID',
                prefixIcon: Icons.person,
                keyboardType: TextInputType.text,
                validator: (value) => Validator.validateField(value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (patientIdController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a patient ID'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(context, patientIdController.text);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (actualPatientId == null || actualPatientId.isEmpty) return;

    print('Adding medicine schedule for patient ID: $actualPatientId');

    // Create or update medicine schedule
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final medicineSchedule = MedicineSchedule(
      id: existingMedicine?.id ?? '',
      index: index,
      userId: authState.user.id!,
      patientId: actualPatientId,
      medicine: medicineFormCubit.medicineNameController.text,
      dose: medicineFormState.dose,
      type: medicineFormState.type,
      schedule: Schedule(
        days: medicineFormState.selectedDays,
        times: medicineFormState.selectedTimes,
        weeksCount: medicineFormState.weeksCount,
        startDate: existingMedicine?.schedule.startDate ?? startDate,
        type:
            medicineFormState.weeksCount > 1
                ? ScheduleType.weekly
                : ScheduleType.daily,
      ),
    );

    context.read<MedicineScheduleBloc>().add(
      MedicineScheduleAdded(medicineSchedule: medicineSchedule),
    );

    // Check if notifications are enabled before scheduling
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    if (notificationsEnabled) {
      // Schedule notification only if notifications are enabled
      final notificationData = NotificationData(
        id: index,
        title: 'Medicine Reminder',
        body: AppMessages.getMedicineNotificationMessage(
          medicineFormState.dose,
          medicineFormCubit.medicineNameController.text,
          medicineFormState.type.name,
        ),
        schedule: Schedule(
          days: medicineFormState.selectedDays,
          times: medicineFormState.selectedTimes,
          weeksCount: medicineFormState.weeksCount,
          startDate: existingMedicine?.schedule.startDate ?? startDate,
          type:
              medicineFormState.weeksCount > 1
                  ? ScheduleType.weekly
                  : ScheduleType.daily,
        ),
        dose: medicineFormState.dose,
      );

      context.read<NotificationBloc>().add(
        WeeklyNotificationScheduled(notification: notificationData),
      );
    }
  }

  Center _dragLable() {
    return Center(
      child: Container(
        width: 48.w,
        height: 4.h,
        margin: EdgeInsets.only(top: 14.h),
        decoration: BoxDecoration(
          color: AppColors.divider.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10).r,
        ),
      ),
    );
  }

  CustomInputCard _medicineNameTextField(BuildContext context) {
    final medcineFormCubit = context.read<MedicineFormCubit>();
    final medcineFormState = medcineFormCubit.state;
    return CustomInputCard(
      label: 'Medicine Name',
      margin: EdgeInsets.zero,
      content: MedicineTextField(
        controller: medcineFormCubit.medicineNameController,
        hintText: 'Enter medicine name',
      ),
      leading: GestureDetector(
        onTap: () => medcineFormCubit.toggleMedicineType(),
        child: Container(
          padding: EdgeInsets.all(AppPadding.p12).w,
          child: ImageIcon(
            AssetImage(medcineFormState.type.icon),
            size: 20.sp,
            color: medcineFormState.type.color,
          ),
        ),
      ),
    );
  }

  CustomInputCard _doseCounter(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final medcineFormCubit = context.read<MedicineFormCubit>();
    final medcineFormState = medcineFormCubit.state;

    if (medcineFormState.type == MedicineType.liquid) {
      return CustomInputCard(
        label: 'Dose',
        margin: EdgeInsets.zero,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${medcineFormState.dose}',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => medcineFormCubit.toggleUnit(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  medcineFormState.isML ? 'ml' : 'cm',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        leading: GestureDetector(
          onTap: () => medcineFormCubit.decrementDose(),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.remove, color: AppColors.primary, size: 20.sp),
          ),
        ),
        trailing: GestureDetector(
          onTap: () => medcineFormCubit.incrementDose(),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: AppColors.primary, size: 20.sp),
          ),
        ),
      );
    } else if (medcineFormState.type == MedicineType.injection) {
      return CustomInputCard(
        label: 'Dose',
        margin: EdgeInsets.zero,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${medcineFormState.dose}',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'units',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        leading: GestureDetector(
          onTap: () => medcineFormCubit.decrementDose(),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.remove, color: AppColors.primary, size: 20.sp),
          ),
        ),
        trailing: GestureDetector(
          onTap: () => medcineFormCubit.incrementDose(),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: AppColors.primary, size: 20.sp),
          ),
        ),
      );
    } else {
      return CustomInputCard(
        label: 'Dose',
        margin: EdgeInsets.zero,
        content: SizedBox(
          width: 70.w,
          child: Center(
            child: Text(
              '${medcineFormState.dose}',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        leading: GestureDetector(
          onTap: () => medcineFormCubit.decrementDose(),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.remove, color: AppColors.primary, size: 20.sp),
          ),
        ),
        trailing: GestureDetector(
          onTap: () => medcineFormCubit.incrementDose(),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: AppColors.primary, size: 20.sp),
          ),
        ),
      );
    }
  }

  Widget _weekdaysWidget(BuildContext context) {
    final medcineFormCubit = context.read<MedicineFormCubit>();
    final medcineFormState = medcineFormCubit.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, bottom: 12.h),
          child: Text(
            'Weekdays',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          height: 56.h,
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            itemCount: medcineFormCubit.weekdays.length,
            itemBuilder: (context, index) {
              final int day = medcineFormCubit.weekdays[index];
              final bool isSelected = medcineFormState.selectedDays.contains(
                day,
              );
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: GestureDetector(
                  onTap: () => medcineFormCubit.toggleDaySelection(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48.w,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          medcineFormCubit.weekdaysNames[index].substring(0, 3),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          width: 4.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _timeIntervalsWidget(
    BuildContext context,
    MedicineFormCubit medcineFormCubit,
    MedicineFormState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
          child: Text(
            'Times',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (state.selectedTimes.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.start,
              children:
                  state.selectedTimes.map((time) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          GestureDetector(
                            onTap: () => medcineFormCubit.removeTime(time),
                            child: Icon(
                              Icons.close,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onPressed: () => _showTimePicker(context, medcineFormCubit),
              icon: Icon(Icons.add_alarm, color: Colors.white, size: 20.sp),
              label: Text(
                'Add Time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _weeksCounter(BuildContext context) {
    return BlocBuilder<MedicineFormCubit, MedicineFormState>(
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Number of Weeks',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color:
                            state.weeksCount > 1
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed:
                            state.weeksCount > 1
                                ? () {
                                  context
                                      .read<MedicineFormCubit>()
                                      .decrementWeeksCount();
                                }
                                : null,
                        icon: Icon(
                          Icons.remove,
                          color:
                              state.weeksCount > 1
                                  ? AppColors.primary
                                  : Colors.grey[400],
                          size: 20.sp,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        '${state.weeksCount}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          context
                              .read<MedicineFormCubit>()
                              .incrementWeeksCount();
                        },
                        icon: Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTimePicker(
    BuildContext context,
    MedicineFormCubit medcineFormCubit,
  ) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.backgroundPrimary,
              onSurface: AppColors.primary,
            ),
            textTheme: Theme.of(context).textTheme.copyWith(
              bodyLarge: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              bodyMedium: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      medcineFormCubit.addTime(formattedTime);
    }
  }
}
