import '../models/gamification.dart';
import 'api_client.dart';

class GamificationService {
  final ApiClient apiClient;

  GamificationService({required this.apiClient});

  // Get my NGO stats
  Future<MyGamificationStats> getMyStats() async {
    final response = await apiClient.get('/api/gamification/my-stats');
    return MyGamificationStats.fromJson(response);
  }

  // Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({
    String? timeframe,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (timeframe != null) queryParams['timeframe'] = timeframe;
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await apiClient.get('/api/gamification/leaderboard', queryParams: queryParams);
    return (response as List).map((item) => LeaderboardEntry.fromJson(item)).toList();
  }

  // Set monthly goal
  Future<void> setMonthlyGoal(int goal) async {
    await apiClient.post('/api/gamification/set-monthly-goal', body: {'goal': goal});
  }

  // Update featured badges
  Future<void> updateFeaturedBadges(List<String> badgeIds) async {
    await apiClient.put('/api/gamification/featured-badges', body: {'badges': badgeIds});
  }

  // Get available badges
  Future<AvailableBadges> getAvailableBadges() async {
    final response = await apiClient.get('/api/gamification/badges/available');
    return AvailableBadges.fromJson(response);
  }

  // Get recent achievements
  Future<RecentAchievements> getRecentAchievements({int? limit}) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await apiClient.get('/api/gamification/achievements/recent', queryParams: queryParams);
    return RecentAchievements.fromJson(response);
  }

  // Get top performers
  Future<TopPerformers> getTopPerformers({String? category}) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;

    final response = await apiClient.get('/api/gamification/community/top-performers', queryParams: queryParams);
    return TopPerformers.fromJson(response);
  }

  // Get public profile of an NGO
  Future<PublicGamificationProfile> getPublicProfile(String ongId) async {
    final response = await apiClient.get('/api/gamification/ong/$ongId/public-profile');
    return PublicGamificationProfile.fromJson(response);
  }

  // Admin functions (if needed)
  Future<void> recalculatePoints() async {
    await apiClient.post('/api/gamification/admin/recalculate-points');
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    return await apiClient.get('/api/gamification/admin/global-stats');
  }
}