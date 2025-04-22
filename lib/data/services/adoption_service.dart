import '../models/adoption_request.dart';
import 'api_client.dart';

class AdoptionService {
  final ApiClient apiClient;

  AdoptionService({required this.apiClient});

  Future<void> requestAdoption(AdoptionRequest request) async {
    await apiClient.post('/api/adoptions', body: request.toJson());
  }

  Future<List<AdoptionRequest>> getAdoptionRequests() async {
    final response = await apiClient.get('/api/adoptions');
    return (response as List).map((json) => AdoptionRequest.fromJson(json)).toList();
  }

  Future<AdoptionRequest> getAdoptionRequestDetails(String id) async {
    final response = await apiClient.get('/api/adoptions/$id');
    return AdoptionRequest.fromJson(response);
  }

  Future<void> approveAdoptionRequest(String id, String notes) async {
    await apiClient.put('/api/adoptions/$id/approve', body: {'notes': notes});
  }

  Future<void> rejectAdoptionRequest(String id, String notes) async {
    await apiClient.put('/api/adoptions/$id/reject', body: {'notes': notes});
  }

  Future<void> cancelAdoptionRequest(String id, String notes) async {
    await apiClient.put('/api/adoptions/$id/cancel', body: {'notes': notes});
  }
}
