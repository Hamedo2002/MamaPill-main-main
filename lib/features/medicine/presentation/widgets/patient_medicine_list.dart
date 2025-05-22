import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/domain/entities/user_profile.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/authentication/presentation/controller/patients/bloc/patients_bloc.dart';
import 'package:mama_pill/features/medicine/presentation/controller/all_medicines_schedule/bloc/all_medicines_schedule_bloc.dart';

class PatientMedicineList extends StatefulWidget {
  const PatientMedicineList({Key? key}) : super(key: key);

  @override
  State<PatientMedicineList> createState() => _PatientMedicineListState();
}

class _PatientMedicineListState extends State<PatientMedicineList>
    with AutomaticKeepAliveClientMixin {
  UserProfile? _selectedPatient;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    // Fetch patients list when widget is initialized
    if (_mounted) {
      // Request patients and medicines in parallel
      context.read<PatientsBloc>().add(const PatientsRequested());
      context.read<AllMedicinesScheduleBloc>().add(
        const AllDispensersFetched(),
      );
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Hide for patients
        if (authState.user.role == UserRole.patient) {
          return const SizedBox.shrink();
        }

        // Initialize patients fetch
        if (_mounted) {
          context.read<PatientsBloc>().add(const PatientsRequested());
        }

        return BlocBuilder<PatientsBloc, PatientsState>(
          builder: (context, patientsState) {
            if (patientsState.status == RequestStatus.loading &&
                patientsState.patients.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (patientsState.patients.isEmpty) {
              return Center(
                child: Text(
                  'No patients found',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<UserProfile>(
                        selectedItemBuilder: (BuildContext context) {
                          return [null, ...patientsState.patients].map<Widget>((UserProfile? profile) {
                            if (profile == null) {
                              return Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Select Patient',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                profile.username ?? 'Patient',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList();
                        },
                      value: _selectedPatient,
                      isExpanded: true,
                      icon: Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.accent,
                          size: 20.sp,
                        ),
                      ),
                      hint: Text(
                        'Select Patient',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: null,
                        labelStyle: TextStyle(
                          color: AppColors.accent,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,

                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        constraints: BoxConstraints(minHeight: 48.h),
                      ),
                      items: [
                        // Add 'Select Patient' as first item with null value
                        DropdownMenuItem<UserProfile>(
                          value: null,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Icon(
                                    Icons.person_add_outlined,
                                    color: AppColors.accent,
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  'Select Patient',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Then add all patients
                        ...patientsState.patients.map((patient) {
                          return DropdownMenuItem(
                            value: patient,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4.h),
                              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36.w,
                                    height: 36.h,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.accent,
                                          Color(0xFF4CAF50),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Center(
                                      child: Text(
                                        patient.username?.isNotEmpty == true ? patient.username![0].toUpperCase() : 'P',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              patient.username ?? 'Patient',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: AppColors.accent.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                'ID: ${patient.patientId}',
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: AppColors.accent,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_outlined,
                                              size: 12.sp,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'Patient since 2025',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (patient) {
                        if (_mounted) {
                          setState(() => _selectedPatient = patient);

                          // Clear medicines if Select Patient is chosen
                          if (patient == null) {
                            context.read<AllMedicinesScheduleBloc>().add(
                              const AllDispensersFetched(dispensers: []),
                            );
                          }
                        }
                      },
                    ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedPatient == null) {
                          // Clear medicines when no patient is selected
                          context.read<AllMedicinesScheduleBloc>().add(
                            const AllDispensersFetched(dispensers: []),
                          );
                          return;
                        }
                        // Start listening to medicines for selected patient
                        context
                            .read<AllMedicinesScheduleBloc>()
                            .startListeningToMedicines(
                              context.read<AuthBloc>().state.user.id!,
                              _selectedPatient!.patientId!,
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Icon(Icons.search_rounded, size: 16.sp),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
