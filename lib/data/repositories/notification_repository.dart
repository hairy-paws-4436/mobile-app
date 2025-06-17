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

  // Methods for all request types
  Future<void> acceptDonation(String donationId, String? notes) async {
    try {
      await notificationService.acceptDonation(donationId, notes);
    } catch (e) {
      throw e;
    }
  }

  Future<void> rejectDonation(String donationId, String? reason) async {
    try {
      await notificationService.rejectDonation(donationId, reason);
    } catch (e) {
      throw e;
    }
  }

  Future<void> acceptAdoption(String adoptionId, String? notes) async {
    try {
      await notificationService.acceptAdoption(adoptionId, notes);
    } catch (e) {
      throw e;
    }
  }

  Future<void> rejectAdoption(String adoptionId, String? reason) async {
    try {
      await notificationService.rejectAdoption(adoptionId, reason);
    } catch (e) {
      throw e;
    }
  }

  Future<void> acceptVisit(String visitId, String? notes) async {
    try {
      await notificationService.acceptVisit(visitId, notes);
    } catch (e) {
      throw e;
    }
  }

  Future<void> rejectVisit(String visitId, String? reason) async {
    try {
      await notificationService.rejectVisit(visitId, reason);
    } catch (e) {
      throw e;
    }
  }
}