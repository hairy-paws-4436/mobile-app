import '../models/post_adoption_models.dart';
import 'api_client.dart';

class PostAdoptionService {
  final ApiClient apiClient;

  PostAdoptionService({required this.apiClient});

  // Adopter endpoints
  Future<List<PostAdoptionFollowUp>> getMyFollowUps({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;

    final response = await apiClient.get('/api/post-adoption/my-followups', queryParams: queryParams);
    return (response as List).map((json) => PostAdoptionFollowUp.fromJson(json)).toList();
  }

  Future<PostAdoptionFollowUp> getFollowUpDetails(String followupId) async {
    final response = await apiClient.get('/api/post-adoption/followup/$followupId');
    return PostAdoptionFollowUp.fromJson(response);
  }

  Future<void> scheduleFollowUps(String adoptionId) async {
    await apiClient.post('/api/post-adoption/schedule/$adoptionId');
  }

  Future<void> completeFollowUp(String followupId, FollowUpFormData formData) async {
    await apiClient.post('/api/post-adoption/followup/$followupId/complete', body: formData.toJson());
  }

  Future<void> skipFollowUp(String followupId) async {
    await apiClient.post('/api/post-adoption/followup/$followupId/skip');
  }

  // NGO endpoints
  Future<PostAdoptionDashboard> getNGODashboard() async {
    final response = await apiClient.get('/api/post-adoption/ong/dashboard');
    return PostAdoptionDashboard.fromJson(response);
  }

  Future<PostAdoptionAnalytics> getNGOAnalytics({String? period}) async {
    final queryParams = <String, String>{};
    if (period != null) queryParams['period'] = period;

    final response = await apiClient.get('/api/post-adoption/ong/analytics', queryParams: queryParams);
    return PostAdoptionAnalytics.fromJson(response);
  }

  Future<List<PostAdoptionFollowUp>> getAtRiskAdoptions() async {
    final response = await apiClient.get('/api/post-adoption/ong/at-risk');
    return (response as List).map((json) => PostAdoptionFollowUp.fromJson(json)).toList();
  }

  Future<void> startIntervention(String followupId) async {
    await apiClient.post('/api/post-adoption/ong/intervention/$followupId');
  }

  // Admin endpoints
  Future<Map<String, dynamic>> getAdminStats() async {
    final response = await apiClient.get('/api/post-adoption/admin/stats');
    return response;
  }

  Future<void> sendReminders() async {
    await apiClient.post('/api/post-adoption/admin/send-reminders');
  }
}