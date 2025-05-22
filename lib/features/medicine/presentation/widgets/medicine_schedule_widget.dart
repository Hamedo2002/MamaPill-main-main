import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mama_pill/core/presentation/widgets/card_section.dart';
import 'package:mama_pill/core/presentation/widgets/empty_tile.dart';
import 'package:mama_pill/core/resources/messages.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/medicine/presentation/controller/all_medicines_schedule/bloc/all_medicines_schedule_bloc.dart';
import 'package:mama_pill/features/medicine/presentation/components/add_medicine_tile.dart';
import 'package:mama_pill/features/medicine/presentation/components/medicine_schedule_tile.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/calendar/presentation/controller/cubit/calendar_cubit.dart';


class DispenserWidget extends StatefulWidget {
  final String patientId;
  final bool showTodayOnly;

  const DispenserWidget({
    super.key,
    required this.patientId,
    this.showTodayOnly = false,
  });

  @override
  State<DispenserWidget> createState() => _DispenserWidgetState();
}

class _DispenserWidgetState extends State<DispenserWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch medicines only once when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMedicines();
    });
  }
  
  void _fetchMedicines() {
    final authBloc = context.read<AuthBloc>();
    final user = authBloc.state.user;
    final allMedicinesBloc = context.read<AllMedicinesScheduleBloc>();

    // Trigger medicine fetch with the proper patient ID only once
    final effectivePatientId = user.role == UserRole.patient ? user.patientId : widget.patientId;
    allMedicinesBloc.add(AllDispensersFetched(
      dispensers: [],
      patientId: effectivePatientId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    List<MedicineSchedule> _getTodayMedicines(List<MedicineSchedule> medicines) {
      final selectedDate = context.read<CalendarCubit>().state;
      final weekday = selectedDate.weekday;
      
      return medicines.where((medicine) {
        // First check if we have a valid start date
        if (medicine.schedule.startDate == null) return false;
        final startDate = medicine.schedule.startDate!;
        
        // If selected date is before start date, don't show
        if (selectedDate.isBefore(startDate)) return false;
        
        // Check if this is a scheduled day of the week
        if (!medicine.schedule.days.contains(weekday)) return false;
        
        // Calculate weeks since start
        final daysSinceStart = selectedDate.difference(startDate).inDays;
        final weeksSinceStart = daysSinceStart ~/ 7;
        
        // If we're past the total number of weeks, don't show
        if (weeksSinceStart >= medicine.schedule.weeksCount) return false;
        
        // For single week schedules, show every scheduled day
        if (medicine.schedule.weeksCount == 1) return true;
        
        // For multi-week schedules, check if this is an active week
        return weeksSinceStart % medicine.schedule.weeksCount == 0;
      }).toList();
    }


    return BlocBuilder<CalendarCubit, DateTime>(
      builder: (context, selectedDate) {
        return BlocBuilder<AllMedicinesScheduleBloc, AllMedicinesScheduleState>(
          builder: (context, state) {
            final medicines = state.dispensers;
            final todayMedicines = _getTodayMedicines(medicines);

            return Column(children: [
              if (widget.showTodayOnly && todayMedicines.isNotEmpty) ...[  
                // Today's Medicines Section
                CardSection(
                  title: "Today's Medicines",
                  itemCount: todayMedicines.length,
                  itemBuilder: (context, index) {
                    return MedicineScheduleTile(medicineSchedule: todayMedicines[index]);
                  },
                ),
              ] else if (widget.showTodayOnly) ...[  
                // Empty Today's Medicines Section
                CardSection(
                  title: "Today's Medicines",
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return const EmptyTile(message: 'No medicines for this day');
                  },
                ),
              ] else ...[  
                // Medicines Section
                CardSection(
                  title: 'Medicines',
                  itemCount: medicines.length + 1, // Show medicines + add button
                  itemBuilder: (context, index) {
                    // Always show the Add Medicine button as the last item
                    if (index == medicines.length) {
                      return BlocProvider.value(
                        value: context.read<AuthBloc>(),
                        child: AddMedicineTile(
                          patientId: widget.patientId,
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
            ]);
          },
        );
      },
    );
  }


}
