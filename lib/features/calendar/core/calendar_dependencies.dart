import 'package:mama_pill/core/services/service_locator.dart';
import 'package:mama_pill/features/calendar/presentation/controller/cubit/calendar_cubit.dart';

class CalendarDependencies {
  static void registerDependencies() {
    sl.registerLazySingleton<CalendarCubit>(() => CalendarCubit());
  }
}
