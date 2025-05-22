import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/features/calendar/presentation/component/calendar_week_table.dart';
import 'package:mama_pill/features/calendar/presentation/controller/cubit/calendar_cubit.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({
    super.key,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> with AutomaticKeepAliveClientMixin {
  late final CalendarCubit _calendarCubit;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _calendarCubit = context.read<CalendarCubit>();
  }
  
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: AppMargin.mediumH,
      padding: AppPadding.small,
      height: AppHeight.h130.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20).w,
        color: AppColors.primary.withOpacity(0.1),
      ),
      child: BlocBuilder<CalendarCubit, DateTime>(
        bloc: _calendarCubit,
        builder: (context, state) {
          // Only build the calendar if the widget is not disposed
          if (_disposed) {
            return const SizedBox.shrink();
          }
          return CustomCalendar(caledarCubit: _calendarCubit);
        },
      ),
    );
  }
}
