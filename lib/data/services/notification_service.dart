import '../models/notification.dart';
import 'api_client.dart';

class NotificationService {
  final ApiClient apiClient;

  NotificationService({required this.apiClient});

  Future<List<AppNotification>> getNotifications() async {
    final response = await apiClient.get('/api/notifications');
    return (response as List).map((json) => AppNotification.fromJson(json)).toList();
  }

  Future<void> markNotificationAsRead(String id) async {
    await apiClient.post('/api/notifications/$id/read');
  }

  Future<void> markAllNotificationsAsRead() async {
    await apiClient.post('/api/notifications/read-all');
  }

  Future<void> deleteNotification(String id) async {
    await apiClient.delete('/api/notifications/$id');
  }

  // Methods for all request types
  Future<void> acceptDonation(String donationId, String? notes) async {
    final data = <String, dynamic>{};
    if (notes != null && notes.isNotEmpty) {
      data['notes'] = notes;
    }

    await apiClient.put('/api/donations/$donationId/confirm', body: data);
  }

  Future<void> rejectDonation(String donationId, String? reason) async {
    final data = <String, dynamic>{};
    if (reason != null && reason.isNotEmpty) {
      data['reason'] = reason;
    }

    await apiClient.put('/api/donations/$donationId/cancel', body: data);
  }

  Future<void> acceptAdoption(String adoptionId, String? notes) async {
    final data = <String, dynamic>{};
    if (notes != null && notes.isNotEmpty) {
      data['notes'] = notes;
    }

    await apiClient.put('/api/adoptions/$adoptionId/approve', body: data);
  }

  Future<void> rejectAdoption(String adoptionId, String? reason) async {
    final data = <String, dynamic>{};
    if (reason != null && reason.isNotEmpty) {
      data['reason'] = reason;
    }

    await apiClient.put('/api/adoptions/$adoptionId/reject', body: data);
  }

  Future<void> acceptVisit(String visitId, String? notes) async {
    final data = <String, dynamic>{};
    if (notes != null && notes.isNotEmpty) {
      data['notes'] = notes;
    }

    await apiClient.put('/api/visits/$visitId/approve', body: data);
  }

  Future<void> rejectVisit(String visitId, String? reason) async {
    final data = <String, dynamic>{};
    if (reason != null && reason.isNotEmpty) {
      data['reason'] = reason;
    }

    await apiClient.put('/api/visits/$visitId/reject', body: data);
  }
}