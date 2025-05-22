import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/features/calendar/presentation/controller/cubit/calendar_cubit.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({
    super.key,
    required this.caledarCubit,
  });

  final CalendarCubit caledarCubit;

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> with AutomaticKeepAliveClientMixin {
  bool _mounted = true;
  DateTime? _lastSelectedDay;
  
  @override
  void initState() {
    super.initState();
    _lastSelectedDay = widget.caledarCubit.state;
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!_mounted) return;
    
    // Prevent excessive state updates by checking if the day has actually changed
    // Use our cached _lastSelectedDay to avoid accessing the cubit if it might be closed
    if (_lastSelectedDay != null && isSameDay(selectedDay, _lastSelectedDay!)) {
      return; // Don't update if it's the same day
    }
    
    // Update our local cache first
    _lastSelectedDay = selectedDay;
    
    // Use a microtask to ensure we don't emit during build phase
    Future.microtask(() {
      if (_mounted) {
        widget.caledarCubit.changeSelectedDate(selectedDay);
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Cache the focused day locally to avoid accessing the cubit directly
    // This prevents issues if the cubit is closed
    final focusedDay = _lastSelectedDay ?? widget.caledarCubit.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: focusedDay,
          calendarFormat: CalendarFormat.week,
          rowHeight: 45,
          selectedDayPredicate: (day) => isSameDay(day, focusedDay),
          onDaySelected: _onDaySelected,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(
              fontSize: AppFontSize.f16.sp,
              fontWeight: FontWeight.w500,
            ),
            selectedTextStyle: TextStyle(
              fontSize: AppFontSize.f16.sp,
              color: AppColors.backgroundSecondary,
              fontWeight: FontWeight.bold,
            ),
            todayTextStyle: TextStyle(
              fontSize: AppFontSize.f16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            headerPadding: EdgeInsets.zero,
            leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.accent),
            rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.accent),
            titleTextStyle: TextStyle(
              fontSize: AppFontSize.f20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          daysOfWeekHeight: 25,
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppFontSize.f16.sp,
              color: AppColors.textPrimary,
            ),
            weekendStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppFontSize.f16.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
