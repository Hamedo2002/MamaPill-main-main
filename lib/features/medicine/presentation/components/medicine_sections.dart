import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mama_pill/core/helpers/date_time_formatter.dart';
import 'package:mama_pill/core/presentation/widgets/card_section.dart';
import 'package:mama_pill/core/resources/strings.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine.dart';
import 'package:mama_pill/core/presentation/widgets/empty_tile.dart';
import 'package:mama_pill/features/medicine/presentation/components/medicine_tile.dart';
import 'package:mama_pill/features/medicine/presentation/widgets/patient_medicine_list.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_schedule/bloc/medicine_schedule_bloc.dart';

class MedicineSection extends StatelessWidget {
  const MedicineSection({
    super.key,
    required this.medicines,
    required this.currentWeekday,
  });
  final List<Medicine> medicines;
  final int currentWeekday;

  @override
  Widget build(BuildContext context) {
    final String currentWeekdayName =
        DateTimeFormatter.getWeekdayName(currentWeekday);
    return Column(
      children: [
        CardSection(
          title: '$currentWeekdayName\'s Medications',
          itemCount: medicines.isNotEmpty ? medicines.length : 1,
          itemBuilder: (context, index) {
            if (medicines.isEmpty) {
              return const EmptyTile(message: AppStrings.noMedicines);
            } else {
              // Provide MedicineScheduleBloc to MedicineTile
              return BlocProvider.value(
                value: context.read<MedicineScheduleBloc>(),
                child: MedicineTile(medicine: medicines[index]),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.user.role != UserRole.patient) {
              return CardSection(
                title: 'Patient Medicines',
                itemCount: 1,
                itemBuilder: (context, index) => const PatientMedicineList(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
