import 'package:equatable/equatable.dart';
import '../../../data/models/event.dart';

abstract class EventState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventsLoaded extends EventState {
  final List<Event> events;

  EventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class EventDetailsLoaded extends EventState {
  final Event event;

  EventDetailsLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

class EventCreated extends EventState {
  final Event event;

  EventCreated(this.event);

  @override
  List<Object?> get props => [event];
}

class EventUpdated extends EventState {
  final Event event;

  EventUpdated(this.event);

  @override
  List<Object?> get props => [event];
}

class EventDeleted extends EventState {}

class EventError extends EventState {
  final String message;

  EventError(this.message);

  @override
  List<Object?> get props => [message];
}
