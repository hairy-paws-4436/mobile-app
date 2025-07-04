import '../models/animal_profile.dart';
import '../models/recommendation.dart';
import '../models/user_preferences.dart';
import '../services/matching_service.dart';

class MatchingRepository {
  final MatchingService matchingService;

  MatchingRepository({required this.matchingService});

  // User Preferences
  Future<UserPreferences> createOrUpdatePreferences(Map<String, dynamic> preferencesData) async {
    try {
      return await matchingService.createOrUpdatePreferences(preferencesData);
    } catch (e) {
      throw e;
    }
  }

  Future<UserPreferences?> getUserPreferences() async {
    try {
      return await matchingService.getUserPreferences();
    } catch (e) {
      throw e;
    }
  }

  Future<PreferencesStatus> getPreferencesStatus() async {
    try {
      return await matchingService.getPreferencesStatus();
    } catch (e) {
      throw e;
    }
  }

  // Animal Profile
  Future<AnimalProfile> createAnimalProfile(String animalId, Map<String, dynamic> profileData) async {
    try {
      return await matchingService.createAnimalProfile(animalId, profileData);
    } catch (e) {
      throw e;
    }
  }

  Future<AnimalProfile?> getAnimalProfile(String animalId) async {
    try {
      return await matchingService.getAnimalProfile(animalId);
    } catch (e) {
      throw e;
    }
  }

  // Recommendations
  Future<RecommendationsResponse> getRecommendations({
    int? limit,
    double? minScore,
    bool? includeSpecialNeeds,
  }) async {
    try {
      return await matchingService.getRecommendations(
        limit: limit,
        minScore: minScore,
        includeSpecialNeeds: includeSpecialNeeds,
      );
    } catch (e) {
      throw e;
    }
  }

  Future<CompatibilityAnalysis> getCompatibilityAnalysis(String animalId) async {
    try {
      return await matchingService.getCompatibilityAnalysis(animalId);
    } catch (e) {
      throw e;
    }
  }
}