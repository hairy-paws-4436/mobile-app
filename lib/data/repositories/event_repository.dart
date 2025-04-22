import '../models/event.dart';
import '../services/event_service.dart';

class EventRepository {
  final EventService eventService;

  EventRepository({required this.eventService});

  Future<List<Event>> getEvents() async {
    try {
      return await eventService.getEvents();
    } catch (e) {
      throw e;
    }
  }

  Future<Event> getEventDetails(String id) async {
    try {
      return await eventService.getEventDetails(id);
    } catch (e) {
      throw e;
    }
  }

  Future<Event> createEvent(Map<String, dynamic> eventData, String? imagePath) async {
    try {
      return await eventService.createEvent(eventData, imagePath);
    } catch (e) {
      throw e;
    }
  }

  Future<Event> updateEvent(String id, Map<String, dynamic> eventData) async {
    try {
      return await eventService.updateEvent(id, eventData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await eventService.deleteEvent(id);
    } catch (e) {
      throw e;
    }
  }
}
