import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/event_repository.dart';
import 'event_event.dart';
import 'event_state.dart';


class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository eventRepository;

  EventBloc({required this.eventRepository}) : super(EventInitial()) {
    on<FetchEventsEvent>(_onFetchEvents);
    on<FetchEventDetailsEvent>(_onFetchEventDetails);
    on<CreateEventEvent>(_onCreateEvent);
    on<UpdateEventEvent>(_onUpdateEvent);
    on<DeleteEventEvent>(_onDeleteEvent);
  }

  Future<void> _onFetchEvents(
      FetchEventsEvent event,
      Emitter<EventState> emit,
      ) async {
    if (state is! EventsLoaded) {
      emit(EventLoading());
    }
    try {
      final events = await eventRepository.getEvents();
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onFetchEventDetails(
      FetchEventDetailsEvent event,
      Emitter<EventState> emit,
      ) async {
    emit(EventLoading());
    try {
      final eventDetails = await eventRepository.getEventDetails(event.eventId);
      emit(EventDetailsLoaded(eventDetails));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onCreateEvent(
      CreateEventEvent event,
      Emitter<EventState> emit,
      ) async {
    emit(EventLoading());
    try {
      final createdEvent = await eventRepository.createEvent(
        event.eventData,
        event.imagePath,
      );
      emit(EventCreated(createdEvent));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onUpdateEvent(
      UpdateEventEvent event,
      Emitter<EventState> emit,
      ) async {
    emit(EventLoading());
    try {
      final updatedEvent = await eventRepository.updateEvent(
        event.eventId,
        event.eventData,
      );
      emit(EventUpdated(updatedEvent));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onDeleteEvent(
      DeleteEventEvent event,
      Emitter<EventState> emit,
      ) async {
    emit(EventLoading());
    try {
      await eventRepository.deleteEvent(event.eventId);
      emit(EventDeleted());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }
}
