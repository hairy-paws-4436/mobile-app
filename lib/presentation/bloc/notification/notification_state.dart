import 'package:equatable/equatable.dart';
import '../../../data/models/notification.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<AppNotification> notifications;
  NotificationsLoaded(this.notifications);
  @override
  List<Object?> get props => [notifications];
}

class NotificationMarkedAsRead extends NotificationState {}
class AllNotificationsMarkedAsRead extends NotificationState {}
class NotificationDeleted extends NotificationState {}

// States for all request handling
class DonationAccepted extends NotificationState {}
class DonationRejected extends NotificationState {}
class AdoptionAccepted extends NotificationState {}
class AdoptionRejected extends NotificationState {}
class VisitAccepted extends NotificationState {}
class VisitRejected extends NotificationState {}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}