import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/medicine/presentation/controller/all_medicines_schedule/bloc/all_medicines_schedule_bloc.dart';

class PatientSearch extends StatefulWidget {
  const PatientSearch({Key? key}) : super(key: key);

  @override
  State<PatientSearch> createState() => _PatientSearchState();
}

class _PatientSearchState extends State<PatientSearch> {
  final TextEditingController _searchController = TextEditingController();
  String? _currentPatientId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final canSearchPatients = authState.user.role == UserRole.staff || authState.user.role == UserRole.doctor;
        
        // If not staff or doctor, don't show the search
        if (!canSearchPatients) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Patient',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Enter Patient ID',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () {
                      final patientId = _searchController.text.trim();
                      if (patientId.isNotEmpty) {
                        setState(() => _currentPatientId = patientId);
                        // Trigger medicine fetch for the specific patient
                        context.read<AllMedicinesScheduleBloc>().add(
                              AllDispensersFetched(
                                patientId: patientId,
                              ),
                            );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text('Search'),
                  ),
                ],
              ),
              if (_currentPatientId != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      'Showing medicines for Patient ID: $_currentPatientId',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    TextButton(
                      onPressed: () {
                        setState(() => _currentPatientId = null);
                        _searchController.clear();
                        // Clear patient ID in the bloc and reset medicines
                        final userId = context.read<AuthBloc>().state.user.id;
                        if (userId != null && userId.isNotEmpty) {
                          context.read<AllMedicinesScheduleBloc>().startListeningToMedicines(userId, null);
                        }
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
