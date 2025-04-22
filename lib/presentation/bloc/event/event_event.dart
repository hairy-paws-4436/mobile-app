import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchEventsEvent extends EventEvent {}

class FetchEventDetailsEvent extends EventEvent {
  final String eventId;

  FetchEventDetailsEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class CreateEventEvent extends EventEvent {
  final Map<String, dynamic> eventData;
  final String? imagePath;

  CreateEventEvent({
    required this.eventData,
    this.imagePath,
  });

  @override
  List<Object?> get props => [eventData, imagePath];
}

class UpdateEventEvent extends EventEvent {
  final String eventId;
  final Map<String, dynamic> eventData;

  UpdateEventEvent({
    required this.eventId,
    required this.eventData,
  });

  @override
  List<Object?> get props => [eventId, eventData];
}

class DeleteEventEvent extends EventEvent {
  final String eventId;

  DeleteEventEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

