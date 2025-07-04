import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/gamification_repository.dart';

import 'gamification_event.dart';
import 'gamification_state.dart';

class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GamificationRepository gamificationRepository;

  GamificationBloc({required this.gamificationRepository}) : super(GamificationInitial()) {
    on<GetMyStatsEvent>(_onGetMyStats);
    on<RefreshMyStatsEvent>(_onRefreshMyStats);
    on<GetLeaderboardEvent>(_onGetLeaderboard);
    on<SetMonthlyGoalEvent>(_onSetMonthlyGoal);
    on<UpdateFeaturedBadgesEvent>(_onUpdateFeaturedBadges);
    on<GetAvailableBadgesEvent>(_onGetAvailableBadges);
    on<GetRecentAchievementsEvent>(_onGetRecentAchievements);
    on<GetTopPerformersEvent>(_onGetTopPerformers);
    on<GetPublicProfileEvent>(_onGetPublicProfile);
    on<RecalculatePointsEvent>(_onRecalculatePoints);
    on<GetGlobalStatsEvent>(_onGetGlobalStats);
    on<ClearGamificationStateEvent>(_onClearGamificationState);
  }

  Future<void> _onGetMyStats(
      GetMyStatsEvent event,
      Emitter<GamificationState> emit,
      ) async {
    emit(GamificationLoading());
    try {
      final stats = await gamificationRepository.getMyStats();
      emit(MyStatsLoaded(stats));
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onRefreshMyStats(
      RefreshMyStatsEvent event,
      Emitter<GamificationState> emit,
      ) async {
    try {
      final stats = await gamificationRepository.getMyStats();
      emit(MyStatsLoaded(stats));
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onGetLeaderboard(
      GetLeaderboardEvent event,
      Emitter<GamificationState> emit,
      ) async {
    emit(GamificationLoading());
    try {
      final leaderboard = await gamificationRepository.getLeaderboard(
        timeframe: event.timeframe,
        limit: event.limit,
      );
      emit(LeaderboardLoaded(leaderboard, timeframe: event.timeframe));
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onSetMonthlyGoal(
      SetMonthlyGoalEvent event,
      Emitter<GamificationState> emit,
      ) async {
    emit(GamificationLoading());
    try {
      await gamificationRepository.setMonthlyGoal(event.goal);
      emit(MonthlyGoalSet(event.goal));
      // Refresh stats after setting goal
      final stats = await gamificationRepository.getMyStats();
      emit(MyStatsLoaded(stats));
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onUpdateFeaturedBadges(
      UpdateFeaturedBadgesEvent event,
      Emitter<GamificationState> emit,
      ) async {
    emit(GamificationLoading());
    try {
      await gamificationRepository.updateFeaturedBadges(event.badgeIds);
      emit(FeaturedBadgesUpdated(event.badgeIds));
      // Refresh stats after updating badges
      final stats = await gamificationRepository.getMyStats();
      emit(MyStatsLoaded(stats));
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onGetAvailableBadges(
      GetAvailableBadgesEvent event,
      Emitter<GamificationState> emit,
      ) async {
    emit(GamificationLoading());
    try {
      final badges = await gamificationRepository.getAvailableBadges();
      emit(AvailableBadgesLoaded(badges));
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onGetRecentAchievements(
      GetRecentAchievementsEvent event,
      Emitter<GamificationState> emit,
      ) async {
    emit(GamificationLoading());
    try {
      final achievements = await gamificationRepository.getRecentAchievements(
        limit: event.limit,
      );
      emit(RecentAchievementsLoaded(achievements));
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onGetTopPerformers(
      GetTopPerformersEvent event,
      Emitter<GamificationState> emit,
      ) async {
    emit(GamificationLoading());
    try {
      final performers = await gamificationRepository.getTopPerformers(
        category: event.category,
      );
      emit(TopPerformersLoaded(performers));
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onGetPublicProfile(
      GetPublicProfileEvent event,
      Emitter<GamificationState> emit,
      ) async {
    emit(GamificationLoading());
    try {
      final profile = await gamificationRepository.getPublicProfile(event.ongId);
      emit(PublicProfileLoaded(profile, event.ongId));
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onRecalculatePoints(
      RecalculatePointsEvent event,
      Emitter<GamificationState> emit,
      ) async {
    emit(GamificationLoading());
    try {
      await gamificationRepository.recalculatePoints();
      emit(PointsRecalculated());
      // Refresh stats after recalculation
      final stats = await gamificationRepository.getMyStats();
      emit(MyStatsLoaded(stats));
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onGetGlobalStats(
      GetGlobalStatsEvent event,
      Emitter<GamificationState> emit,
      ) async {
    emit(GamificationLoading());
    try {
      final stats = await gamificationRepository.getGlobalStats();
      emit(GlobalStatsLoaded(stats));
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onClearGamificationState(
      ClearGamificationStateEvent event,
      Emitter<GamificationState> emit,
      ) async {
    emit(GamificationInitial());
  }
}