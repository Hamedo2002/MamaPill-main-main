import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/presentation/widgets/custom_button.dart';
import 'package:mama_pill/core/presentation/widgets/custom_input_card.dart';
import 'package:mama_pill/core/presentation/widgets/custom_progress_indicator.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/core/services/service_locator.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/core/utils/extensions.dart';
import 'package:mama_pill/core/utils/top_notification_utils.dart';
import 'package:mama_pill/features/medicine/data/models/schedule_model.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_form/cubit/medicine_form_cubit.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_schedule/bloc/medicine_schedule_bloc.dart';
import 'package:mama_pill/features/notifications/presentation/controller/bloc/notification_bloc.dart';
import 'package:mama_pill/features/notifications/domain/entities/notification.dart';

class EditDispenserForm extends StatefulWidget {
  const EditDispenserForm({
    super.key,
    required this.medicine,
    required this.index,
  });
  final MedicineSchedule medicine;
  final int index;

  @override
  State<EditDispenserForm> createState() => _EditDispenserFormState();
}

class _EditDispenserFormState extends State<EditDispenserForm> {
  late MedicineFormCubit _medicineFormCubit;

  @override
  void initState() {
    super.initState();
    _medicineFormCubit = sl<MedicineFormCubit>();
    // Initialize cubit state only once
    _medicineFormCubit.medicineNameController.text = widget.medicine.medicine;
    _medicineFormCubit.emit(
      _medicineFormCubit.state.copyWith(
      type: widget.medicine.type,
      dose: widget.medicine.dose,
      selectedDays: widget.medicine.schedule.days,
      selectedTimes: widget.medicine.schedule.times,
      weeksCount: widget.medicine.schedule.weeksCount,
      ),
    );
  }

  @override
  void dispose() {
    _medicineFormCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medicineTypeColor = _medicineFormCubit.state.type.color;
    final medicineTypeIcon = _medicineFormCubit.state.type.icon;
    return MultiBlocProvider(
      providers: [
        BlocProvider<MedicineFormCubit>.value(value: _medicineFormCubit),
        BlocProvider(create: (context) => sl<MedicineScheduleBloc>()),
        BlocProvider(create: (context) => sl<NotificationBloc>()),
      ],
      child: BlocListener<MedicineScheduleBloc, MedicineScheduleState>(
        listener: (context, state) {
          if (state.saveStatus == RequestStatus.success) {
            TopNotificationUtils.showSuccessNotification(
              context,
              title: 'Success',
              message: 'Medicine updated successfully',
            );
            
            // Close the cubit before navigation
            _medicineFormCubit.close();

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
            return BlocBuilder<MedicineScheduleBloc, MedicineScheduleState>(
                builder: (context, medicineScheduleState) {
                return WillPopScope(
                  onWillPop: () async {
                    // Close the cubit before popping
                    _medicineFormCubit.close();
                    return true;
                  },
                  child: Material(
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
                        Container(
                          padding: EdgeInsets.symmetric(
                                          vertical: 16.h,
                                          horizontal: 20.w,
                                        ),
                          decoration: BoxDecoration(
                                          color: medicineTypeColor.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                              width: 48.w,
                                              height: 48.h,
                                decoration: BoxDecoration(
                                                color: medicineTypeColor
                                                    .withOpacity(0.2),
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                  'Edit Medicine',
                                                    style: theme
                                                        .textTheme
                                                        .titleLarge
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              medicineTypeColor,
                                                        ),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    'Update medicine details',
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color:
                                                              Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                            ],
                          ),
                        ),
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
                                        _medicineFormCubit,
                                        medicineFormState,
                                      ),
                                      SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                8.h,
                                16.w,
                                16.h,
                              ),
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
                                      medicineScheduleState.saveStatus ==
                                RequestStatus.loading
                                          ? ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              elevation: 2,
                                            ),
                                            onPressed: null,
                                            child: SizedBox(
                                              width: 24.w,
                                              height: 24.h,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            ),
                                          )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                  elevation: 2,
                                ),
                                onPressed: () async {
                                  // Validate input
                                  if (_medicineFormCubit
                                                  .medicineNameController
                                                  .text
                                                  .isEmpty) {
                                    TopNotificationUtils.showErrorNotification(
                                      context,
                                      title: 'Validation Error',
                                                  message:
                                                      'Please enter a medicine name',
                                    );
                                    return;
                                  }

                                              if (medicineFormState
                                                  .selectedDays
                                                  .isEmpty) {
                                    TopNotificationUtils.showErrorNotification(
                                      context,
                                      title: 'Validation Error',
                                                  message:
                                                      'Please select at least one day',
                                    );
                                    return;
                                  }

                                              if (medicineFormState
                                                  .selectedTimes
                                                  .isEmpty) {
                                    TopNotificationUtils.showErrorNotification(
                                      context,
                                      title: 'Validation Error',
                                      message:
                                          'Please select at least one time',
                                    );
                                    return;
                                  }

                                  final now = DateTime.now();
                                              final startDate =
                                                  widget
                                                              .medicine
                                                              .schedule
                                                              .startDate !=
                                          null
                                      ? DateTime(
                                                        widget
                                                            .medicine
                                                            .schedule
                                                            .startDate!
                                              .year,
                                                        widget
                                                            .medicine
                                                            .schedule
                                                            .startDate!
                                              .month,
                                          widget
                                                            .medicine
                                                            .schedule
                                                            .startDate!
                                                            .day,
                                                      )
                                                      : DateTime(
                                                        now.year,
                                                        now.month,
                                                        now.day,
                                                      );

                                  // Create updated medicine schedule with existing ID
                                  final schedule = ScheduleModel(
                                                days:
                                                    medicineFormState
                                                        .selectedDays,
                                                times:
                                                    medicineFormState
                                                        .selectedTimes,
                                                weeksCount:
                                                    medicineFormState
                                                        .weeksCount,
                                    startDate: startDate,
                                  );

                                              final updatedMedicine =
                                                  MedicineSchedule(
                                    id: widget.medicine.id,
                                                    index:
                                                        widget.medicine.index,
                                                    userId:
                                                        widget.medicine.userId,
                                                    patientId:
                                                        widget
                                                            .medicine
                                                            .patientId,
                                                    medicine:
                                                        _medicineFormCubit
                                                            .medicineNameController
                                                            .text,
                                                    type:
                                                        medicineFormState.type,
                                                    dose:
                                                        medicineFormState.dose,
                                    schedule: schedule,
                                  );

                                  // Cancel old notification
                                              context
                                                  .read<NotificationBloc>()
                                                  .add(
                                        NotificationCanceled(
                                          id: widget.medicine.index,
                                                      schedule:
                                                          widget
                                                              .medicine
                                                              .schedule,
                                        ),
                                      );

                                  // Update medicine in Firestore
                                              context
                                                  .read<MedicineScheduleBloc>()
                                                  .add(
                                        MedicineScheduleAdded(
                                                      medicineSchedule:
                                                          updatedMedicine,
                                        ),
                                      );

                                  // Schedule new notification
                                  context.read<NotificationBloc>().add(
                                        WeeklyNotificationScheduled(
                                          notification: NotificationData(
                                            id: updatedMedicine.index,
                                            title: 'Medicine Reminder',
                                                    body:
                                                        'Time to take ${updatedMedicine.medicine}',
                                                    schedule:
                                                        updatedMedicine
                                                            .schedule,
                                                    dose: updatedMedicine.dose,
                                          ),
                                        ),
                                      );
                                },
                                child: Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
                        ),
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

  Center _dragLable() {
    return Center(
      child: Container(
        width: AppWidth.w48.w,
        height: AppHeight.h4.h,
        margin: const EdgeInsets.only(top: 14).w,
        decoration: BoxDecoration(
          color: AppColors.divider.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10).r,
        ),
      ),
    );
  }

  CustomInputCard _medicineNameTextField(BuildContext context) {
    final medcineFormCubit = context.read<MedicineFormCubit>();
    return CustomInputCard(
      label: 'Medicine Name',
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 0).w,
      width: double.infinity,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0).w,
        child: TextField(
          controller: medcineFormCubit.medicineNameController,
          style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: medcineFormCubit.medicineNameController.text,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
          ),
        ),
      ),
      leading: GestureDetector(
        onTap: () => medcineFormCubit.toggleMedicineType(),
        child: Container(
          padding: const EdgeInsets.all(AppPadding.p12).w,
          child: ImageIcon(
            AssetImage(medcineFormCubit.state.type.icon),
            size: 20.sp,
            color: medcineFormCubit.state.type.color,
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
}
