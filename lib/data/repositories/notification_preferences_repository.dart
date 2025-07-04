import '../models/notification_preferences.dart';
import '../models/notification_templates.dart';
import '../services/notification_preferences_service.dart';

class NotificationPreferencesRepository {
  final NotificationPreferencesService notificationPreferencesService;

  NotificationPreferencesRepository({required this.notificationPreferencesService});

  Future<NotificationPreferences> getNotificationPreferences() async {
    try {
      return await notificationPreferencesService.getNotificationPreferences();
    } catch (e) {
      throw e;
    }
  }

  Future<NotificationPreferences> updateNotificationPreferences(
      Map<String, dynamic> preferences,
      ) async {
    try {
      return await notificationPreferencesService.updateNotificationPreferences(preferences);
    } catch (e) {
      throw e;
    }
  }

  Future<NotificationTemplates> getNotificationTemplates() async {
    try {
      return await notificationPreferencesService.getNotificationTemplates();
    } catch (e) {
      throw e;
    }
  }

  Future<NotificationPreferences> applyTemplate(String templateName) async {
    try {
      return await notificationPreferencesService.applyTemplate(templateName);
    } catch (e) {
      throw e;
    }
  }
}