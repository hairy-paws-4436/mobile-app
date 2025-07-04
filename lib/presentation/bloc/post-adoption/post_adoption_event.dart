import 'package:equatable/equatable.dart';

import '../../../data/models/post_adoption_models.dart';

abstract class PostAdoptionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Adopter Events
class GetMyFollowUpsEvent extends PostAdoptionEvent {
  final String? status;

  GetMyFollowUpsEvent({this.status});

  @override
  List<Object?> get props => [status];
}

class GetFollowUpDetailsEvent extends PostAdoptionEvent {
  final String followupId;

  GetFollowUpDetailsEvent({required this.followupId});

  @override
  List<Object?> get props => [followupId];
}

class ScheduleFollowUpsEvent extends PostAdoptionEvent {
  final String adoptionId;

  ScheduleFollowUpsEvent({required this.adoptionId});

  @override
  List<Object?> get props => [adoptionId];
}

class CompleteFollowUpEvent extends PostAdoptionEvent {
  final String followupId;
  final FollowUpFormData formData;

  CompleteFollowUpEvent({
    required this.followupId,
    required this.formData,
  });

  @override
  List<Object?> get props => [followupId, formData];
}

class SkipFollowUpEvent extends PostAdoptionEvent {
  final String followupId;

  SkipFollowUpEvent({required this.followupId});

  @override
  List<Object?> get props => [followupId];
}

// NGO Events
class GetNGODashboardEvent extends PostAdoptionEvent {}

class GetNGOAnalyticsEvent extends PostAdoptionEvent {
  final String? period;

  GetNGOAnalyticsEvent({this.period});

  @override
  List<Object?> get props => [period];
}

class GetAtRiskAdoptionsEvent extends PostAdoptionEvent {}

class StartInterventionEvent extends PostAdoptionEvent {
  final String followupId;

  StartInterventionEvent({required this.followupId});

  @override
  List<Object?> get props => [followupId];
}

// Admin Events
class GetAdminStatsEvent extends PostAdoptionEvent {}

class SendRemindersEvent extends PostAdoptionEvent {}

// UI Events
class RefreshPostAdoptionDataEvent extends PostAdoptionEvent {}

class ClearPostAdoptionStateEvent extends PostAdoptionEvent {}