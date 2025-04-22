import '../models/event.dart';
import 'api_client.dart';

class EventService {
  final ApiClient apiClient;

  EventService({required this.apiClient});

  Future<List<Event>> getEvents() async {
    final response = await apiClient.get('/api/events');
    return (response as List).map((json) => Event.fromJson(json)).toList();
  }

  Future<Event> getEventDetails(String id) async {
    final response = await apiClient.get('/api/events/$id');
    return Event.fromJson(response);
  }

  Future<Event> createEvent(Map<String, dynamic> eventData, String? imagePath) async {
    final fields = eventData.map((key, value) => MapEntry(key, value.toString()));
    final files = <String, String>{};

    if (imagePath != null) {
      files['image'] = imagePath;
    }

    final response = await apiClient.multipartPost('/api/events', fields: fields, files: files);
    return Event.fromJson(response);
  }

  Future<Event> updateEvent(String id, Map<String, dynamic> eventData) async {
    final response = await apiClient.put('/api/events/$id', body: eventData);
    return Event.fromJson(response);
  }

  Future<void> deleteEvent(String id) async {
    await apiClient.delete('/api/events/$id');
  }
}
