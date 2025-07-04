import '../models/gamification.dart';
import '../services/gamification_service.dart';


class GamificationRepository {
  final GamificationService gamificationService;

  GamificationRepository({required this.gamificationService});

  Future<MyGamificationStats> getMyStats() async {
    try {
      return await gamificationService.getMyStats();
    } catch (e) {
      throw e;
    }
  }

  Future<List<LeaderboardEntry>> getLeaderboard({
    String? timeframe,
    int? limit,
  }) async {
    try {
      return await gamificationService.getLeaderboard(
        timeframe: timeframe,
        limit: limit,
      );
    } catch (e) {
      throw e;
    }
  }

  Future<void> setMonthlyGoal(int goal) async {
    try {
      await gamificationService.setMonthlyGoal(goal);
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateFeaturedBadges(List<String> badgeIds) async {
    try {
      await gamificationService.updateFeaturedBadges(badgeIds);
    } catch (e) {
      throw e;
    }
  }

  Future<AvailableBadges> getAvailableBadges() async {
    try {
      return await gamificationService.getAvailableBadges();
    } catch (e) {
      throw e;
    }
  }

  Future<RecentAchievements> getRecentAchievements({int? limit}) async {
    try {
      return await gamificationService.getRecentAchievements(limit: limit);
    } catch (e) {
      throw e;
    }
  }

  Future<TopPerformers> getTopPerformers({String? category}) async {
    try {
      return await gamificationService.getTopPerformers(category: category);
    } catch (e) {
      throw e;
    }
  }

  Future<PublicGamificationProfile> getPublicProfile(String ongId) async {
    try {
      return await gamificationService.getPublicProfile(ongId);
    } catch (e) {
      throw e;
    }
  }

  Future<void> recalculatePoints() async {
    try {
      await gamificationService.recalculatePoints();
    } catch (e) {
      throw e;
    }
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    try {
      return await gamificationService.getGlobalStats();
    } catch (e) {
      throw e;
    }
  }
}