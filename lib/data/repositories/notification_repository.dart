import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService notificationService;

  NotificationRepository({required this.notificationService});

  Future<List<AppNotification>> getNotifications() async {
    try {
      return await notificationService.getNotifications();
    } catch (e) {
      throw e;
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      await notificationService.markNotificationAsRead(id);
    } catch (e) {
      throw e;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await notificationService.markAllNotificationsAsRead();
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await notificationService.deleteNotification(id);
    } catch (e) {
      throw e;
    }
  }
}
