import 'package:dartz/dartz.dart';
import 'package:mama_pill/core/data/error/failure.dart';
import 'package:mama_pill/features/medicine/domain/entities/schedule.dart';
import 'package:mama_pill/features/notifications/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, Unit>> scheduleWeeklyNotification(
      NotificationData notificationData);
  Future<Either<Failure, Unit>> cancelNotification(int id, Schedule schedule);
}
