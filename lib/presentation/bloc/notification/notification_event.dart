import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchNotificationsEvent extends NotificationEvent {}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;
  MarkNotificationAsReadEvent(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsReadEvent extends NotificationEvent {}

class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;
  DeleteNotificationEvent(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

// Events for donation handling
class AcceptDonationEvent extends NotificationEvent {
  final String donationId;
  final String notificationId;
  final String? notes;

  AcceptDonationEvent({
    required this.donationId,
    required this.notificationId,
    this.notes,
  });

  @override
  List<Object?> get props => [donationId, notificationId, notes];
}

class RejectDonationEvent extends NotificationEvent {
  final String donationId;
  final String notificationId;
  final String? reason;

  RejectDonationEvent({
    required this.donationId,
    required this.notificationId,
    this.reason,
  });

  @override
  List<Object?> get props => [donationId, notificationId, reason];
}

// Events for adoption handling
class AcceptAdoptionEvent extends NotificationEvent {
  final String adoptionId;
  final String notificationId;
  final String? notes;

  AcceptAdoptionEvent({
    required this.adoptionId,
    required this.notificationId,
    this.notes,
  });

  @override
  List<Object?> get props => [adoptionId, notificationId, notes];
}

class RejectAdoptionEvent extends NotificationEvent {
  final String adoptionId;
  final String notificationId;
  final String? reason;

  RejectAdoptionEvent({
    required this.adoptionId,
    required this.notificationId,
    this.reason,
  });

  @override
  List<Object?> get props => [adoptionId, notificationId, reason];
}

// Events for visit handling
class AcceptVisitEvent extends NotificationEvent {
  final String visitId;
  final String notificationId;
  final String? notes;

  AcceptVisitEvent({
    required this.visitId,
    required this.notificationId,
    this.notes,
  });

  @override
  List<Object?> get props => [visitId, notificationId, notes];
}

class RejectVisitEvent extends NotificationEvent {
  final String visitId;
  final String notificationId;
  final String? reason;

  RejectVisitEvent({
    required this.visitId,
    required this.notificationId,
    this.reason,
  });

  @override
  List<Object?> get props => [visitId, notificationId, reason];
}