import 'package:get_it/get_it.dart';
import 'package:mama_pill/features/reports/data/repository/patient_records_repository_impl.dart';
import 'package:mama_pill/features/reports/domain/repository/patient_records_repository.dart';
import 'package:mama_pill/features/reports/presentation/controller/patient_records/bloc/patient_records_bloc.dart';

class ReportsDependencies {
  static void init(GetIt sl) {
    // Repository
    sl.registerLazySingleton<PatientRecordsRepository>(
      () => PatientRecordsRepositoryImpl(),
    );

    // BLoC
    sl.registerFactory<PatientRecordsBloc>(
      () => PatientRecordsBloc(repository: sl()),
    );
  }
}
