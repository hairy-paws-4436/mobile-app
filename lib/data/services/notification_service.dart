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
}
