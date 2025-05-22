import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mama_pill/core/presentation/view/header_widget.dart';
import 'package:mama_pill/core/services/service_locator.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/authentication/presentation/controller/patients/bloc/patients_bloc.dart';
import 'package:mama_pill/features/calendar/presentation/controller/cubit/calendar_cubit.dart';
import 'package:mama_pill/features/calendar/presentation/widgets/calendar_widget.dart';
import 'package:mama_pill/features/medicine/presentation/widgets/medicine_schedule_widget.dart';
import 'package:mama_pill/features/medicine/presentation/widgets/patient_medicine_list.dart';
import 'package:mama_pill/features/medicine/presentation/controller/all_medicines_schedule/bloc/all_medicines_schedule_bloc.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_schedule/bloc/medicine_schedule_bloc.dart';
import 'package:mama_pill/core/utils/top_notification_utils.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.authBloc});
  final AuthBloc authBloc;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  late final List<BlocBase> _blocs;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    // Use existing singletons instead of creating new instances
    _blocs = [
      sl<CalendarCubit>(),
      sl<AllMedicinesScheduleBloc>(),
      sl<MedicineScheduleBloc>(),
      sl<PatientsBloc>(),
    ];
    
    // Reset the calendar cubit to ensure it's ready to handle new events
    // This is important because the cubit might have been marked as closed
    // but not actually closed since it's a singleton
    sl<CalendarCubit>().reset();
  }

  @override
  void dispose() {
    _mounted = false;
    // Don't close the blocs here since they're singletons managed by the service locator
    // This prevents the 'Cannot emit after close' errors
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Debug logging for user role and auth state
    print('HomeView - Auth state: ${widget.authBloc.state}');
    print(
      'HomeView - Current user role: ${widget.authBloc.state.user.role.name}',
    );
    print('HomeView - Current user ID: ${widget.authBloc.state.user.id}');
    print(
      'HomeView - Is authenticated: ${widget.authBloc.state.status == AppStatus.authenticated}',
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authBloc),
        BlocProvider.value(value: _blocs[0] as CalendarCubit),
        BlocProvider.value(value: _blocs[1] as AllMedicinesScheduleBloc),
        BlocProvider.value(value: _blocs[2] as MedicineScheduleBloc),
        BlocProvider.value(value: _blocs[3] as PatientsBloc),
      ],
      child: BlocListener<MedicineScheduleBloc, MedicineScheduleState>(
        listener: (context, state) {
          // Show notifications for success or failure
          if (state.saveStatus == RequestStatus.success) {
            TopNotificationUtils.showSuccessNotification(
              context,
              title: 'Success',
              message: state.message,
            );

            // Refresh the list after showing notification
            if (_mounted) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_mounted) {
                  final allMedicinesBloc =
                      context.read<AllMedicinesScheduleBloc>();
                  final userId = widget.authBloc.state.user.id;
                  if (userId != null && userId.isNotEmpty) {
                    allMedicinesBloc.add(AllDispensersFetched(dispensers: []));
                  }
                }
              });
            }
          } else if (state.saveStatus == RequestStatus.failure) {
            TopNotificationUtils.showErrorNotification(
              context,
              title: 'Error',
              message: state.message,
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            minimum: const EdgeInsets.only(top: 42).h,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  HeaderWidget(authBloc: widget.authBloc),
                  const CalendarWidget(),
                  const SizedBox(height: 20),
                  // Today's Medications
                  DispenserWidget(patientId: '', showTodayOnly: true),
                  const SizedBox(height: 20),
                  // Patient selection for staff only
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state.user.role == UserRole.staff ||
                          state.user.role == UserRole.doctor) {
                        return Column(
                          children: const [
                            PatientMedicineList(),
                            SizedBox(height: 20),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // Medicines section
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final patientId =
                          state.user.role == UserRole.patient
                              ? state.user.patientId ?? ''
                              : '';

                      return DispenserWidget(
                        patientId: patientId,
                        showTodayOnly: false,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
