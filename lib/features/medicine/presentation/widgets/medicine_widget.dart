import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/presentation/widgets/card_section.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/features/calendar/presentation/controller/cubit/calendar_cubit.dart';
import 'package:mama_pill/features/medicine/presentation/controller/all_medicines_schedule/bloc/all_medicines_schedule_bloc.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine/cubit/medicine_cubit.dart';

class MedicineWidget extends StatelessWidget {
  const MedicineWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Access existing blocs from the parent context
    final allMedicinesBloc = context.read<AllMedicinesScheduleBloc>();
    final calendarCubit = context.read<CalendarCubit>();
    
    return BlocProvider<MedicineCubit>(
      // Use the existing blocs to create the MedicineCubit
      create: (context) => MedicineCubit(allMedicinesBloc, calendarCubit),
      child: BlocBuilder<MedicineCubit, MedicineState>(
        builder: (context, state) {
          return CardSection(
            title: "Today's Medications",
            itemCount: state.medicines.isEmpty ? 1 : state.medicines.length,
            itemBuilder: (context, index) {
              if (state.medicines.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        size: 48.sp,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No medicines for this day',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              final medicine = state.medicines[index];
              return ListTile(
                leading: Icon(
                  Icons.medication,
                  color: AppColors.primary,
                ),
                title: Text(medicine.name),
                subtitle: Text('${medicine.dose} ${medicine.type.name} at ${medicine.time}'),
              );
            },
          );
        },
      ),
    );
  }
}
