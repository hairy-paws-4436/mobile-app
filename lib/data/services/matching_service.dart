import '../models/animal_profile.dart';
import '../models/recommendation.dart';
import '../models/user_preferences.dart';
import 'api_client.dart';

class MatchingService {
  final ApiClient apiClient;

  MatchingService({required this.apiClient});

  // User Preferences
  Future<UserPreferences> createOrUpdatePreferences(Map<String, dynamic> preferencesData) async {
    final response = await apiClient.post('/api/matching/preferences', body: preferencesData);
    return UserPreferences.fromJson(response['preferences']);
  }

  Future<UserPreferences?> getUserPreferences() async {
    final response = await apiClient.get('/api/matching/preferences');
    if (response['hasPreferences'] == true) {
      return UserPreferences.fromJson(response['preferences']);
    }
    return null;
  }

  Future<PreferencesStatus> getPreferencesStatus() async {
    final response = await apiClient.get('/api/matching/preferences/status');
    return PreferencesStatus.fromJson(response);
  }

  // Animal Profile
  Future<AnimalProfile> createAnimalProfile(String animalId, Map<String, dynamic> profileData) async {
    final response = await apiClient.post('/api/matching/animals/$animalId/profile', body: profileData);
    return AnimalProfile.fromJson(response['profile']);
  }

  Future<AnimalProfile?> getAnimalProfile(String animalId) async {
    final response = await apiClient.get('/api/matching/animals/$animalId/profile');
    if (response['hasProfile'] == true) {
      return AnimalProfile.fromJson(response['profile']);
    }
    return null;
  }

  // Recommendations
  Future<RecommendationsResponse> getRecommendations({
    int? limit,
    double? minScore,
    bool? includeSpecialNeeds,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (minScore != null) queryParams['minScore'] = minScore.toString();
    if (includeSpecialNeeds != null) queryParams['includeSpecialNeeds'] = includeSpecialNeeds.toString();

    final response = await apiClient.get('/api/matching/recommendations', queryParams: queryParams);
    return RecommendationsResponse.fromJson(response);
  }

  Future<CompatibilityAnalysis> getCompatibilityAnalysis(String animalId) async {
    final response = await apiClient.get('/api/matching/recommendations/$animalId/compatibility');
    return CompatibilityAnalysis.fromJson(response);
  }
}