import 'package:flutter/material.dart' show TimeOfDay;
import 'package:mama_pill/core/helpers/date_time_formatter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class TimeZoneHelper {
  static Future<void> init() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Use local timezone
      final now = DateTime.now();
      final timeZoneName = now.timeZoneName;
      
      // Default to UTC if we can't determine the timezone
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        print('Warning: Could not set timezone $timeZoneName, using local system timezone');
        // Use the system's local timezone offset
        final offset = now.timeZoneOffset.inHours;
        final sign = offset >= 0 ? '+' : '';
        final locationName = 'Etc/GMT$sign${-offset}';
        tz.setLocalLocation(tz.getLocation(locationName));
      }

      print('Timezone initialized: ${tz.local.name}');
    } catch (e) {
      print('Error initializing timezone: $e');
      // Don't rethrow, just continue with UTC
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  static tz.TZDateTime convertDateTimeToTimeZone(
      DateTime dateTime, String timeZone) {
    final location = tz.getLocation(timeZone);
    final convertedDateTime = tz.TZDateTime.from(dateTime, location);
    return convertedDateTime;
  }

  static tz.TZDateTime scheduleDaily(TimeOfDay timeOfDay) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return scheduledDate.isBefore(now)
        ? tz.TZDateTime.from(
            scheduledDate.add(const Duration(days: 1)), tz.local)
        : tz.TZDateTime.from(scheduledDate, tz.local);
  }

  static tz.TZDateTime scheduleWeekly(TimeOfDay timeOfDay,
      {required List<int> weekday}) {
    tz.TZDateTime scheduledDate = scheduleDaily(timeOfDay);
    while (!weekday.contains(scheduledDate.weekday)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static List<tz.TZDateTime> scheduleMultipleWeekly(
    List<String> times,
    List<int> weekdays,
  ) {
    final scheduledDates = <tz.TZDateTime>[];
    for (final time in times) {
      final formattedTime = DateTimeFormatter.formatTimeOfDay(time);
      final scheduledTime =
          TimeOfDay(hour: formattedTime.hour, minute: formattedTime.minute);
      final scheduledDate = scheduleWeekly(scheduledTime, weekday: weekdays);
      scheduledDates.add(scheduledDate);
    }
    return scheduledDates;
  }
}
