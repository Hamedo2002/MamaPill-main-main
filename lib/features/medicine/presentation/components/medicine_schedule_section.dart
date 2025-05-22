import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/core/presentation/widgets/card_section.dart';
import 'package:mama_pill/core/resources/messages.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/medicine/presentation/components/add_medicine_tile.dart';
import 'package:mama_pill/features/medicine/presentation/components/medicine_schedule_tile.dart';
import 'package:mama_pill/core/presentation/widgets/empty_tile.dart';
import 'package:mama_pill/features/medicine/presentation/controller/all_medicines_schedule/bloc/all_medicines_schedule_bloc.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';

class MedicineScheduleSection extends StatelessWidget {
  const MedicineScheduleSection({
    super.key,
    required this.patientId,
  });

  final String patientId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllMedicinesScheduleBloc, AllMedicinesScheduleState>(
      builder: (context, state) {
        final medicines = state.dispensers;
        final todayMedicines = _getTodayMedicines(medicines);

        return Column(
          children: [
            // Today's Medicines Section
            if (todayMedicines.isNotEmpty) ...[              
              CardSection(
                title: "Today's Medicines",
                itemCount: todayMedicines.length,
                itemBuilder: (context, index) {
                  return MedicineScheduleTile(medicineSchedule: todayMedicines[index]);
                },
              ),
              const SizedBox(height: 20),
            ],

            // All Medicines Section
            CardSection(
              title: 'Medicines',
              itemCount: medicines.length + 1, // Show medicines + add button
              itemBuilder: (context, index) {
                // Always show the Add Medicine button as the last item
                if (index == medicines.length) {
                  return BlocProvider.value(
                    value: context.read<AuthBloc>(),
                    child: AddMedicineTile(
                      patientId: patientId,
                      index: medicines.length + 1
                    ),
                  );
                }

                // Show error message
                if (state.status == RequestStatus.failure && index == 0) {
                  return const EmptyTile(
                      message: AppMessages.failedToLoadMedicines);
                }

                // Show medicines
                if (index < medicines.length) {
                  return MedicineScheduleTile(medicineSchedule: medicines[index]);
                }

                // Show empty state if no medicines
                return const EmptyTile(message: 'No medicines added yet');
              },
            ),
          ],
        );
      },
    );
  }

  List<MedicineSchedule> _getTodayMedicines(List<MedicineSchedule> medicines) {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    
    return medicines.where((medicine) {
      // If no start date is set, medicine is not scheduled
      if (medicine.schedule.startDate == null) return false;
      
      // Check if today is within the schedule days
      return medicine.schedule.days.contains(todayWeekday);
    }).toList();
  }
}
