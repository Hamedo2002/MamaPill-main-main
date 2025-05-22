part of 'medicine_schedule_bloc.dart';

enum NotificationType { success, error, info, warning }

class MedicineScheduleState extends Equatable {
  const MedicineScheduleState({
    this.saveStatus = RequestStatus.initial,
    this.deleteStatus = RequestStatus.initial,
    this.status = RequestStatus.initial,
    this.message = '',
    this.shouldShowNotification = false,
    this.notificationType,
    this.notificationMessage = '',
  });

  final RequestStatus saveStatus;
  final RequestStatus deleteStatus;
  final RequestStatus status;
  final String message;
  final bool shouldShowNotification;
  final NotificationType? notificationType;
  final String notificationMessage;

  MedicineScheduleState copyWith({
    RequestStatus? saveStatus,
    RequestStatus? deleteStatus,
    RequestStatus? status,
    String? message,
    bool? shouldShowNotification,
    NotificationType? notificationType,
    String? notificationMessage,
  }) {
    return MedicineScheduleState(
      saveStatus: saveStatus ?? this.saveStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      status: status ?? this.status,
      message: message ?? this.message,
      shouldShowNotification: shouldShowNotification ?? this.shouldShowNotification,
      notificationType: notificationType ?? this.notificationType,
      notificationMessage: notificationMessage ?? this.notificationMessage,
    );
  }

  @override
  List<Object?> get props => [
        saveStatus,
        deleteStatus,
        status,
        message,
        shouldShowNotification,
        notificationType,
        notificationMessage,
      ];
}
