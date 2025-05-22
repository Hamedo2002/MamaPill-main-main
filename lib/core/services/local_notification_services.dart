import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mama_pill/core/helpers/id_generator.dart';
import 'package:mama_pill/core/helpers/time_zone_helper.dart';
import 'package:mama_pill/features/notifications/presentation/pages/full_screen_notification_page.dart';
import 'package:mama_pill/features/medicine/domain/repositories/medicine_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationServices {
  static FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();

  static Future<bool> init({required bool initSchedule}) async {
    try {
      print('Initializing notifications...');

      // Initialize timezone
      if (initSchedule) {
        await TimeZoneHelper.init();
      }

      // Initialize notifications with default settings first
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const setting = InitializationSettings(android: android, iOS: ios);

      // Create notification channel for Android
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            notification
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        if (androidImplementation == null) {
          print('Error: Could not get Android implementation');
          return false;
        }

        try {
          await androidImplementation.createNotificationChannel(
            const AndroidNotificationChannel(
              'medicine_reminder_channel',
              'Medicine Reminders',
              description: 'Notifications for medicine reminders',
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
            ),
          );
          print('Notification channel created successfully');
        } catch (e) {
          print('Error creating notification channel: $e');
          return false;
        }
      }

      await notification.initialize(
        setting,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notification clicked: ${response.payload}');
          // Update medicine taken status when notification is received
          final payload = response.payload;
          if (payload != null) {
            // Get the MedicineRepository instance and update the status
            final medicineRepository = GetIt.I<MedicineRepository>();
            medicineRepository.updateMedicineTakenStatus(payload, true);
          }
        },
      );

      final permissionGranted = await requestNotificationPermissions();
      print('Notification permission granted: $permissionGranted');

      return permissionGranted;
    } catch (e) {
      print('Error initializing notifications: $e');
      return false;
    }
  }

  static Future<bool> requestNotificationPermissions() async {
    try {
      bool? permissionGranted;

      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            notification
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        permissionGranted =
            await androidImplementation?.requestNotificationsPermission();
        print('Android notification permission requested: $permissionGranted');
      } else if (Platform.isIOS) {
        final IOSFlutterLocalNotificationsPlugin? iOSImplementation =
            notification
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >();
        permissionGranted = await iOSImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        print('iOS notification permission requested: $permissionGranted');
      }

      return permissionGranted ?? false;
    } catch (e) {
      print('Error requesting notification permissions: $e');
      return false;
    }
  }

  static Future<NotificationDetails> getNotificationDetails() async {
    const androidPlatformChannel = AndroidNotificationDetails(
      "medicine_reminder_channel",
      "Medicine Reminders",
      channelDescription: "Notifications for medicine reminders",
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.reminder,
      playSound: true,
      enableVibration: true,
    );
    const iOSPlatformChannel = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(
      android: androidPlatformChannel,
      iOS: iOSPlatformChannel,
    );
  }

  static Future<void> showFullScreenNotification(
    BuildContext context, {
    required String medicineName,
    required String dosage,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (context) => FullScreenNotificationPage(
              medicineName: medicineName,
              dosage: dosage,
            ),
      ),
    );
  }

  static Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    List<DateTime> scheduledDates, {
    String? medicineId,
    int? dose,
  }) async {
    try {
      // Check if notifications are enabled in settings
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? true;

      if (!notificationsEnabled) {
        print('Notifications are disabled in settings, skipping schedule');
        return;
      }

      print(
        'Scheduling notification for $title at ${scheduledDates.length} times',
      );
      final notificationDetails = await getNotificationDetails();

      final notificationBody = dose != null ? '$body (Dose: $dose)' : body;

      for (var date in scheduledDates) {
        final scheduledTime = tz.TZDateTime.from(date, tz.local);
        print('Scheduling notification for ${scheduledTime.toString()}');

        await notification.zonedSchedule(
          id,
          title,
          notificationBody,
          scheduledTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: medicineId,
        );
        print(
          'Successfully scheduled notification for ${scheduledTime.toString()}',
        );
      }
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelNotification(
    int id,
    List<tz.TZDateTime> scheduledDates,
  ) async {
    try {
      for (final date in scheduledDates) {
        final notificationId = IdGenerator.generateNotificationId(id, date);
        await notification.cancel(notificationId);
        print('Cancelled notification $notificationId');
      }
    } catch (e) {
      print('Error cancelling notification: $e');
      rethrow;
    }
  }
}
