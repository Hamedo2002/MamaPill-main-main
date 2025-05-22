import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/presentation/view/header_widget.dart';
import 'package:mama_pill/core/services/service_locator.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/authentication/presentation/controller/patients/bloc/patients_bloc.dart';
import 'package:mama_pill/features/reports/presentation/controller/patient_records/bloc/patient_records_bloc.dart';
import 'package:mama_pill/features/reports/presentation/view/patient_list_view.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({Key? key, required this.authBloc}) : super(key: key);
  
  final AuthBloc authBloc;

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> with AutomaticKeepAliveClientMixin {
  late PatientsBloc _patientsBloc;
  
  @override
  void initState() {
    super.initState();
    _patientsBloc = sl<PatientsBloc>();
    
    // Request patients list when the view is initialized
    _refreshPatientsList();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh patients list when dependencies change (e.g., when returning to this screen)
    _refreshPatientsList();
  }
  
  void _refreshPatientsList() {
    // Trigger a refresh of the patients list
    _patientsBloc.add(const PatientsRequested());
  }
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authBloc),
        BlocProvider.value(value: _patientsBloc),
        BlocProvider.value(value: sl<PatientRecordsBloc>()),
      ],
      child: Scaffold(
        body: SafeArea(
          minimum: const EdgeInsets.only(top: 42).h,
          child: Column(
            children: [
              HeaderWidget(authBloc: widget.authBloc),
              SizedBox(height: 8.h),
              Expanded(
                // Show patient list for all roles (patient, doctor, staff)
                // The PatientListView handles showing appropriate content
                // based on the user's role
                child: PatientListView(authBloc: widget.authBloc),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
