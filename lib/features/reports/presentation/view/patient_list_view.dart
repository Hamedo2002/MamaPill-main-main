import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/domain/entities/user_profile.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/authentication/presentation/controller/patients/bloc/patients_bloc.dart';
import 'package:mama_pill/features/reports/presentation/view/patient_record_view.dart';

class PatientListView extends StatefulWidget {
  const PatientListView({Key? key, required this.authBloc}) : super(key: key);
  
  final AuthBloc authBloc;

  @override
  State<PatientListView> createState() => _PatientListViewState();
}

class _PatientListViewState extends State<PatientListView> with AutomaticKeepAliveClientMixin {
  bool _mounted = true;
  late PatientsBloc _patientsBloc;

  @override
  void initState() {
    super.initState();
    // Store reference to the PatientsBloc
    _patientsBloc = context.read<PatientsBloc>();
    // Fetch patients list when widget is initialized
    if (_mounted) {
      _patientsBloc.add(const PatientsRequested());
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
        // For patients, show just their own name in the list
        if (authState.user.role == UserRole.patient) {
          return Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Medical Record',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'View your medical information and diagnosis',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildPatientCard(context, authState.user),
              ],
            ),
          );
        }

        return BlocBuilder<PatientsBloc, PatientsState>(
          builder: (context, patientsState) {
            if (patientsState.status == RequestStatus.loading && patientsState.patients.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (patientsState.patients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64.sp,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No patients found',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Patients who register will appear here',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient Records',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Select a patient to view or edit their medical record',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: ListView.builder(
                      itemCount: patientsState.patients.length,
                      itemBuilder: (context, index) {
                        final patient = patientsState.patients[index];
                        return _buildPatientCard(context, patient);
                      },
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

  Widget _buildPatientCard(BuildContext context, UserProfile patient) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () async {
          // Navigate to PatientRecordView and await result
          final shouldRefresh = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => PatientRecordView(
                patientId: patient.patientId ?? patient.id ?? '',
                patientName: patient.username ?? 'Unknown',
                authBloc: widget.authBloc,
              ),
            ),
          );
          
          // If we got a true result, refresh the patients list
          if (shouldRefresh == true && mounted) {
            // Use the stored reference to avoid looking up a deactivated widget
            _patientsBloc.add(const PatientsRequested());
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.personal_injury_rounded,
                    color: Colors.orange,
                    size: 28.sp,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.username ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Patient ID: ${patient.patientId ?? 'Not assigned'}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (patient.email != null && patient.email!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          patient.email!,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary.withOpacity(0.8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.accent,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
