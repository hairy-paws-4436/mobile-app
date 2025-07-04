import 'package:equatable/equatable.dart';

import '../../../data/models/post_adoption_models.dart';

abstract class PostAdoptionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PostAdoptionInitial extends PostAdoptionState {}

class PostAdoptionLoading extends PostAdoptionState {}

// Adopter States
class MyFollowUpsLoaded extends PostAdoptionState {
  final List<PostAdoptionFollowUp> followUps;

  MyFollowUpsLoaded(this.followUps);

  @override
  List<Object?> get props => [followUps];
}

class FollowUpDetailsLoaded extends PostAdoptionState {
  final PostAdoptionFollowUp followUp;

  FollowUpDetailsLoaded(this.followUp);

  @override
  List<Object?> get props => [followUp];
}

class FollowUpsScheduled extends PostAdoptionState {
  final String adoptionId;

  FollowUpsScheduled(this.adoptionId);

  @override
  List<Object?> get props => [adoptionId];
}

class FollowUpCompleted extends PostAdoptionState {
  final String followupId;

  FollowUpCompleted(this.followupId);

  @override
  List<Object?> get props => [followupId];
}

class FollowUpSkipped extends PostAdoptionState {
  final String followupId;

  FollowUpSkipped(this.followupId);

  @override
  List<Object?> get props => [followupId];
}

// NGO States
class NGODashboardLoaded extends PostAdoptionState {
  final PostAdoptionDashboard dashboard;

  NGODashboardLoaded(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

class NGOAnalyticsLoaded extends PostAdoptionState {
  final PostAdoptionAnalytics analytics;

  NGOAnalyticsLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

class AtRiskAdoptionsLoaded extends PostAdoptionState {
  final List<PostAdoptionFollowUp> atRiskAdoptions;

  AtRiskAdoptionsLoaded(this.atRiskAdoptions);

  @override
  List<Object?> get props => [atRiskAdoptions];
}

class InterventionStarted extends PostAdoptionState {
  final String followupId;

  InterventionStarted(this.followupId);

  @override
  List<Object?> get props => [followupId];
}

// Admin States
class AdminStatsLoaded extends PostAdoptionState {
  final Map<String, dynamic> stats;

  AdminStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class RemindersSent extends PostAdoptionState {}

// Success States
class PostAdoptionSuccess extends PostAdoptionState {
  final String message;

  PostAdoptionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PostAdoptionError extends PostAdoptionState {
  final String message;

  PostAdoptionError(this.message);

  @override
  List<Object?> get props => [message];
}