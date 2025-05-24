import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/services/service_locator.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/core/utils/top_notification_utils.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/reports/domain/entities/patient_medical_record.dart';
import 'package:mama_pill/features/reports/presentation/controller/patient_records/bloc/patient_records_bloc.dart';

class PatientRecordView extends StatefulWidget {
  final String patientId;
  final String patientName;
  final AuthBloc authBloc;

  const PatientRecordView({
    Key? key,
    required this.patientId,
    required this.patientName,
    required this.authBloc,
  }) : super(key: key);

  @override
  State<PatientRecordView> createState() => _PatientRecordViewState();
}

class _PatientRecordViewState extends State<PatientRecordView> {
  final _formKey = GlobalKey<FormState>();
  late final PatientRecordsBloc _recordsBloc;
  bool _isEditMode = false;
  
  // Form controllers
  final _ageController = TextEditingController();
  String _selectedGender = ''; // For dropdown
  final _primaryDiagnosisController = TextEditingController();
  final _secondaryDiagnosisController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedBloodType = ''; // For dropdown
  final _bloodPressureController = TextEditingController();
  final _sugarPercentageController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  
  // Options for dropdowns
  final List<String> _genderOptions = ['m', 'f'];
  final Map<String, String> _genderLabels = {
    'm': 'Male',
    'f': 'Female',
  };
  final List<String> _bloodTypeOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  
  @override
  void initState() {
    super.initState();
    _recordsBloc = sl<PatientRecordsBloc>();
    _recordsBloc.add(PatientRecordFetched(patientId: widget.patientId));
  }

  @override
  void dispose() {
    _ageController.dispose();
    _primaryDiagnosisController.dispose();
    _secondaryDiagnosisController.dispose();
    _allergiesController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bloodPressureController.dispose();
    _sugarPercentageController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  void _loadRecordData(PatientMedicalRecord record) {
    _ageController.text = record.age.toString();
    _selectedGender = record.gender;
    _primaryDiagnosisController.text = record.primaryDiagnosis;
    _secondaryDiagnosisController.text = record.secondaryDiagnoses.join(', ');
    _allergiesController.text = record.allergies;
    _weightController.text = record.weight.toString();
    _heightController.text = record.height.toString();
    _selectedBloodType = record.bloodType;
    _bloodPressureController.text = record.bloodPressure;
    _sugarPercentageController.text = record.sugarPercentage.toString();
    _emergencyContactController.text = record.emergencyContact;
  }

  void _clearForm() {
    _ageController.clear();
    _selectedGender = '';
    _primaryDiagnosisController.clear();
    _secondaryDiagnosisController.clear();
    _allergiesController.clear();
    _weightController.clear();
    _heightController.clear();
    _selectedBloodType = '';
    _bloodPressureController.clear();
    _sugarPercentageController.clear();
    _emergencyContactController.clear();
  }

  PatientMedicalRecord _buildRecordFromForm() {
    // Parse secondary diagnoses
    final secondaryDiagnoses = _secondaryDiagnosisController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return PatientMedicalRecord(
      id: _recordsBloc.state.selectedRecord?.id,
      patientId: widget.patientId,
      patientName: widget.patientName,
      age: int.tryParse(_ageController.text) ?? 0,
      gender: _selectedGender,
      primaryDiagnosis: _primaryDiagnosisController.text,
      secondaryDiagnoses: secondaryDiagnoses,
      allergies: _allergiesController.text,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      height: double.tryParse(_heightController.text) ?? 0.0,
      bloodType: _selectedBloodType,
      bloodPressure: _bloodPressureController.text,
      sugarPercentage: double.tryParse(_sugarPercentageController.text) ?? 0.0,
      emergencyContact: _emergencyContactController.text,
      lastUpdated: DateTime.now(),
      updatedBy: widget.authBloc.state.user.username ?? 'Unknown user',
    );
  }

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      final record = _buildRecordFromForm();
      
      if (_recordsBloc.state.selectedRecord != null) {
        _recordsBloc.add(PatientRecordUpdated(record: record));
      } else {
        _recordsBloc.add(PatientRecordSaved(record: record));
      }
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, String recordId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_forever, color: Colors.red, size: 48.sp),
                SizedBox(height: 16.h),
                Text(
                  'Delete Medical Record',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Are you sure you want to delete this patient\'s medical record? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          // Trigger record deletion
                          _recordsBloc.add(PatientRecordDeleted(recordId: recordId));
                          // Return to patient list after deletion
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    // Check if current user is a patient or a doctor/staff
    final userRole = widget.authBloc.state.user.role;
    final bool canEdit = userRole != UserRole.patient;
    
    return BlocProvider.value(
      value: _recordsBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.patientName}\'s Medical Record',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Return true to indicate we need to refresh the patients list
              Navigator.of(context).pop(true);
            },
          ),
          actions: [
            BlocBuilder<PatientRecordsBloc, PatientRecordsState>(
              builder: (context, state) {
                // Only show edit/save button if the user can edit
                if (state.selectedRecord != null && canEdit) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit/Save button
                      IconButton(
                        icon: Icon(_isEditMode ? Icons.save : Icons.edit),
                        onPressed: () {
                          if (_isEditMode) {
                            _saveRecord();
                          } else {
                            setState(() {
                              _isEditMode = true;
                            });
                          }
                        },
                      ),
                      
                      // Delete button - only visible to doctors
                      if (widget.authBloc.state.user.role == UserRole.doctor && !_isEditMode)
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Show confirmation dialog
                            _showDeleteConfirmation(context, state.selectedRecord!.id!);
                          },
                        ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<PatientRecordsBloc, PatientRecordsState>(
          listener: (context, state) {
            if (state.status == RequestStatus.success && state.message != null) {
              TopNotificationUtils.showSuccessNotification(
                context,
                title: 'Success',
                message: state.message!,
              );
              
              if (_isEditMode) {
                setState(() {
                  _isEditMode = false;
                });
              }
            } else if (state.status == RequestStatus.failure && state.message != null) {
              TopNotificationUtils.showErrorNotification(
                context,
                title: 'Error',
                message: state.message!,
              );
            }

            // Load record data into form when available
            if (state.status == RequestStatus.success && state.selectedRecord != null) {
              _loadRecordData(state.selectedRecord!);
            }
          },
          builder: (context, state) {
            if (state.status == RequestStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.selectedRecord == null && !_isEditMode) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_information_outlined,
                      size: 64.sp,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No medical record found',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      canEdit 
                          ? 'Create a new medical record for this patient'
                          : 'No medical record has been created yet',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    if (canEdit) ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditMode = true;
                          _clearForm();
                        });
                      },
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 18.sp,
                      ),
                      label: Text(
                        'Create Medical Record',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show either read-only view or edit form
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: _isEditMode && canEdit 
                  ? _buildEditForm() 
                  : _buildReadOnlyView(state.selectedRecord!, canEdit),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReadOnlyView(PatientMedicalRecord record, bool canEdit) {
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy - HH:mm');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Record section
        _buildSectionHeader('Patient Information'),
        _buildInfoTile('Age', '${record.age} years'),
        _buildInfoTile('Gender', record.gender),
        _buildInfoTile('Weight', '${record.weight} kg'),
        _buildInfoTile('Height', '${record.height} cm'),
        _buildInfoTile('Blood Type', record.bloodType.isNotEmpty ? record.bloodType : 'Not specified'),
        _buildInfoTile('Blood Pressure', record.bloodPressure.isNotEmpty ? record.bloodPressure : 'Not specified'),
        _buildInfoTile('Blood Sugar', '${record.sugarPercentage} %'),
        
        SizedBox(height: 24.h),
        _buildSectionHeader('Medical Information'),
        _buildInfoTile('Primary Diagnosis', record.primaryDiagnosis),
        if (record.secondaryDiagnoses.isNotEmpty)
          _buildInfoTile('Secondary Diagnoses', record.secondaryDiagnoses.join(', ')),
        _buildInfoTile('Allergies', record.allergies.isNotEmpty ? record.allergies : 'None reported'),
        
        if (record.emergencyContact.isNotEmpty) ...[
          SizedBox(height: 24.h),
          _buildSectionHeader('Emergency Contact'),
          _buildInfoTile('Contact Information', record.emergencyContact),
        ],
        
        SizedBox(height: 24.h),
        _buildSectionHeader('Record Information'),
        _buildInfoTile('Last Updated', dateFormat.format(record.lastUpdated)),
        _buildInfoTile('Updated By', record.updatedBy),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Patient Information'),
          SizedBox(height: 8.h),
          
          // Age field
          TextFormField(
            controller: _ageController,
            decoration: InputDecoration(
              hintText: 'Age (years)',
              hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              prefixIcon: Icon(Icons.calendar_today, size: 20.sp),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter age';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          
          // Gender dropdown
          DropdownButtonFormField<String>(
            value: _genderOptions.contains(_selectedGender) ? _selectedGender : null,
            decoration: InputDecoration(
              hintText: 'Gender',
              hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              prefixIcon: Icon(Icons.person, size: 20.sp),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            hint: Text('Select gender', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select gender';
              }
              return null;
            },
            items: _genderOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  _genderLabels[value] ?? value,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedGender = newValue ?? '';
              });
            },
          ),
          SizedBox(height: 16.h),
          
          // Weight field
          TextFormField(
            controller: _weightController,
            decoration: InputDecoration(
              hintText: 'Weight (kg)',
              hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              prefixIcon: Icon(Icons.monitor_weight, size: 20.sp),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter weight';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          
          // Height field
          TextFormField(
            controller: _heightController,
            decoration: InputDecoration(
              hintText: 'Height (cm)',
              hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              prefixIcon: Icon(Icons.height, size: 20.sp),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter height';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          
          // Blood type dropdown
          DropdownButtonFormField<String>(
            value: _bloodTypeOptions.contains(_selectedBloodType) ? _selectedBloodType : null,
            decoration: InputDecoration(
              hintText: 'Blood Type',
              hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              prefixIcon: Icon(Icons.bloodtype, size: 20.sp),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            hint: Text('Select blood type', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            items: _bloodTypeOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedBloodType = newValue ?? '';
              });
            },
          ),
          SizedBox(height: 16.h),
          
          // Blood Pressure field
          TextFormField(
            controller: _bloodPressureController,
            decoration: InputDecoration(
              hintText: 'Blood Pressure (e.g. 120/80)',
              hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              prefixIcon: Icon(Icons.favorite, size: 20.sp),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          
          // Sugar Percentage field
          TextFormField(
            controller: _sugarPercentageController,
            decoration: InputDecoration(
              hintText: 'Blood Sugar Percentage (%)',
              hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              prefixIcon: Icon(Icons.water_drop, size: 20.sp),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
              }
              return null;
            },
          ),
          SizedBox(height: 24.h),
          
          _buildSectionHeader('Medical Information'),
          SizedBox(height: 8.h),
          
          // Primary diagnosis field
          TextFormField(
            controller: _primaryDiagnosisController,
            decoration: InputDecoration(
              hintText: 'Primary Diagnosis',
              hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              prefixIcon: Icon(Icons.medical_information, size: 20.sp),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter primary diagnosis';
              }
              return null;
            },
            maxLines: 2,
          ),
          SizedBox(height: 16.h),
          
          // Secondary diagnoses field
          TextFormField(
            controller: _secondaryDiagnosisController,
            decoration: InputDecoration(
              hintText: 'Secondary Diagnoses (comma separated)',
              hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              prefixIcon: Icon(Icons.medical_services, size: 20.sp),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            maxLines: 3,
          ),
          SizedBox(height: 16.h),
          
          // Allergies field
          TextFormField(
            controller: _allergiesController,
            decoration: InputDecoration(
              hintText: 'Allergies',
              hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              prefixIcon: Icon(Icons.warning_amber, size: 20.sp),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            maxLines: 2,
          ),
          SizedBox(height: 24.h),
          
          _buildSectionHeader('Emergency Contact'),
          SizedBox(height: 8.h),
          
          // Emergency contact field
          TextFormField(
            controller: _emergencyContactController,
            decoration: InputDecoration(
              hintText: 'Emergency Contact Information',
              hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              prefixIcon: Icon(Icons.contacts, size: 20.sp),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 32.h),
          
          // Form buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditMode = false;
                    // If we don't have a saved record, reload the form data
                    if (_recordsBloc.state.selectedRecord != null) {
                      _loadRecordData(_recordsBloc.state.selectedRecord!);
                    } else {
                      _clearForm();
                    }
                  });
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              ElevatedButton(
                onPressed: _saveRecord,
                child: Text(
                  'Save Record',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Divider(
          color: AppColors.primary.withOpacity(0.5),
          thickness: 1,
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w, 
            child: Text(label, style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            )),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(value, style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            )),
          ),
        ],
      ),
    );
  }
}
