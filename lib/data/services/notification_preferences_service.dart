// Agrega estos logs temporales en notification_preferences_service.dart

import '../models/notification_preferences.dart';
import '../models/notification_templates.dart';
import 'api_client.dart';
import 'dart:convert'; // Agregar esta línea al inicio del archivo

class NotificationPreferencesService {
  final ApiClient apiClient;

  NotificationPreferencesService({required this.apiClient});

  Future<NotificationPreferences> getNotificationPreferences() async {
    final response = await apiClient.get('/api/notification-preferences');
    return NotificationPreferences.fromJson(response);
  }

  Future<NotificationPreferences> updateNotificationPreferences(
      Map<String, dynamic> preferences,
      ) async {
    // DEBUG: Imprimir TODOS los datos que se van a enviar
    print('=== DEBUGGING PREFERENCES UPDATE ===');
    print('Raw preferences data:');
    preferences.forEach((key, value) {
      print('  $key: $value (${value.runtimeType})');
    });
    print('JSON encoded: ${jsonEncode(preferences)}');
    print('=====================================');

    final response = await apiClient.put('/api/notification-preferences', body: preferences);

    print('Response from server: $response');

    // El backend devuelve { message: "...", preferences: {...} }
    if (response['preferences'] != null) {
      return NotificationPreferences.fromJson(response['preferences']);
    }
    // Si no hay estructura anidada, usar la respuesta directa
    return NotificationPreferences.fromJson(response);
  }

  Future<NotificationTemplates> getNotificationTemplates() async {
    final response = await apiClient.get('/api/notification-preferences/templates');
    return NotificationTemplates.fromJson(response);
  }

  Future<NotificationPreferences> applyTemplate(String templateName) async {
    print('Applying template: $templateName');

    final response = await apiClient.put(
      '/api/notification-preferences/template/$templateName',
      body: {'templateName': templateName},
    );

    print('Template response: $response');

    // El backend devuelve { message: "...", preferences: {...} }
    if (response['preferences'] != null) {
      return NotificationPreferences.fromJson(response['preferences']);
    }
    return NotificationPreferences.fromJson(response);
  }
}