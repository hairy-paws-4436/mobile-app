import 'package:equatable/equatable.dart';

abstract class GamificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// My Stats Events
class GetMyStatsEvent extends GamificationEvent {}

class RefreshMyStatsEvent extends GamificationEvent {}

// Leaderboard Events
class GetLeaderboardEvent extends GamificationEvent {
  final String? timeframe;
  final int? limit;

  GetLeaderboardEvent({this.timeframe, this.limit});

  @override
  List<Object?> get props => [timeframe, limit];
}

// Goal Events
class SetMonthlyGoalEvent extends GamificationEvent {
  final int goal;

  SetMonthlyGoalEvent({required this.goal});

  @override
  List<Object?> get props => [goal];
}

// Featured Badges Events
class UpdateFeaturedBadgesEvent extends GamificationEvent {
  final List<String> badgeIds;

  UpdateFeaturedBadgesEvent({required this.badgeIds});

  @override
  List<Object?> get props => [badgeIds];
}

// Available Badges Events
class GetAvailableBadgesEvent extends GamificationEvent {}

// Recent Achievements Events
class GetRecentAchievementsEvent extends GamificationEvent {
  final int? limit;

  GetRecentAchievementsEvent({this.limit});

  @override
  List<Object?> get props => [limit];
}

// Top Performers Events
class GetTopPerformersEvent extends GamificationEvent {
  final String? category;

  GetTopPerformersEvent({this.category});

  @override
  List<Object?> get props => [category];
}

// Public Profile Events
class GetPublicProfileEvent extends GamificationEvent {
  final String ongId;

  GetPublicProfileEvent({required this.ongId});

  @override
  List<Object?> get props => [ongId];
}

// Admin Events
class RecalculatePointsEvent extends GamificationEvent {}

class GetGlobalStatsEvent extends GamificationEvent {}

// Clear Events
class ClearGamificationStateEvent extends GamificationEvent {}