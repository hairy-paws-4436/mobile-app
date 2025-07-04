import 'package:equatable/equatable.dart';

import '../../../data/models/gamification.dart';

abstract class GamificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GamificationInitial extends GamificationState {}

class GamificationLoading extends GamificationState {}

// My Stats States
class MyStatsLoaded extends GamificationState {
  final MyGamificationStats stats;

  MyStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

// Leaderboard States
class LeaderboardLoaded extends GamificationState {
  final List<LeaderboardEntry> leaderboard;
  final String? timeframe;

  LeaderboardLoaded(this.leaderboard, {this.timeframe});

  @override
  List<Object?> get props => [leaderboard, timeframe];
}

// Goal States
class MonthlyGoalSet extends GamificationState {
  final int goal;

  MonthlyGoalSet(this.goal);

  @override
  List<Object?> get props => [goal];
}

// Featured Badges States
class FeaturedBadgesUpdated extends GamificationState {
  final List<String> badgeIds;

  FeaturedBadgesUpdated(this.badgeIds);

  @override
  List<Object?> get props => [badgeIds];
}

// Available Badges States
class AvailableBadgesLoaded extends GamificationState {
  final AvailableBadges badges;

  AvailableBadgesLoaded(this.badges);

  @override
  List<Object?> get props => [badges];
}

// Recent Achievements States
class RecentAchievementsLoaded extends GamificationState {
  final RecentAchievements achievements;

  RecentAchievementsLoaded(this.achievements);

  @override
  List<Object?> get props => [achievements];
}

// Top Performers States
class TopPerformersLoaded extends GamificationState {
  final TopPerformers performers;

  TopPerformersLoaded(this.performers);

  @override
  List<Object?> get props => [performers];
}

// Public Profile States
class PublicProfileLoaded extends GamificationState {
  final PublicGamificationProfile profile;
  final String ongId;

  PublicProfileLoaded(this.profile, this.ongId);

  @override
  List<Object?> get props => [profile, ongId];
}

// Admin States
class PointsRecalculated extends GamificationState {}

class GlobalStatsLoaded extends GamificationState {
  final Map<String, dynamic> stats;

  GlobalStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

// Error State
class GamificationError extends GamificationState {
  final String message;

  GamificationError(this.message);

  @override
  List<Object?> get props => [message];
}