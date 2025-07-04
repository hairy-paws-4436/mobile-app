import 'package:equatable/equatable.dart';

abstract class NotificationPreferencesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotificationPreferencesEvent extends NotificationPreferencesEvent {}

class LoadNotificationTemplatesEvent extends NotificationPreferencesEvent {}

class UpdateNotificationPreferencesEvent extends NotificationPreferencesEvent {
  final Map<String, dynamic> preferences;

  UpdateNotificationPreferencesEvent({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

class ApplyNotificationTemplateEvent extends NotificationPreferencesEvent {
  final String templateName;

  ApplyNotificationTemplateEvent({required this.templateName});

  @override
  List<Object?> get props => [templateName];
}

class UpdateGlobalNotificationsEvent extends NotificationPreferencesEvent {
  final bool enabled;

  UpdateGlobalNotificationsEvent({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class UpdateQuietHoursEvent extends NotificationPreferencesEvent {
  final bool enabled;
  final String? startTime;
  final String? endTime;

  UpdateQuietHoursEvent({
    required this.enabled,
    this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [enabled, startTime, endTime];
}

class UpdatePreferredChannelsEvent extends NotificationPreferencesEvent {
  final List<String> channels;

  UpdatePreferredChannelsEvent({required this.channels});

  @override
  List<Object?> get props => [channels];
}

class UpdateAdoptionNotificationsEvent extends NotificationPreferencesEvent {
  final bool requestsEnabled;
  final String requestsFrequency;
  final bool statusEnabled;
  final String statusFrequency;

  UpdateAdoptionNotificationsEvent({
    required this.requestsEnabled,
    required this.requestsFrequency,
    required this.statusEnabled,
    required this.statusFrequency,
  });

  @override
  List<Object?> get props => [requestsEnabled, requestsFrequency, statusEnabled, statusFrequency];
}

class UpdateMatchingNotificationsEvent extends NotificationPreferencesEvent {
  final bool newMatchesEnabled;
  final String newMatchesFrequency;
  final bool newAnimalsEnabled;
  final String newAnimalsFrequency;

  UpdateMatchingNotificationsEvent({
    required this.newMatchesEnabled,
    required this.newMatchesFrequency,
    required this.newAnimalsEnabled,
    required this.newAnimalsFrequency,
  });

  @override
  List<Object?> get props => [newMatchesEnabled, newMatchesFrequency, newAnimalsEnabled, newAnimalsFrequency];
}

class UpdateEventNotificationsEvent extends NotificationPreferencesEvent {
  final bool eventRemindersEnabled;
  final String eventRemindersFrequency;
  final bool newEventsEnabled;
  final String newEventsFrequency;

  UpdateEventNotificationsEvent({
    required this.eventRemindersEnabled,
    required this.eventRemindersFrequency,
    required this.newEventsEnabled,
    required this.newEventsFrequency,
  });

  @override
  List<Object?> get props => [eventRemindersEnabled, eventRemindersFrequency, newEventsEnabled, newEventsFrequency];
}

class UpdateFilteringPreferencesEvent extends NotificationPreferencesEvent {
  final List<String>? preferredAnimalTypes;
  final int maxDistanceKm;
  final bool onlyHighCompatibility;

  UpdateFilteringPreferencesEvent({
    this.preferredAnimalTypes,
    required this.maxDistanceKm,
    required this.onlyHighCompatibility,
  });

  @override
  List<Object?> get props => [preferredAnimalTypes, maxDistanceKm, onlyHighCompatibility];
}

class UpdateMarketingPreferencesEvent extends NotificationPreferencesEvent {
  final bool promotionalEnabled;
  final bool newsletterEnabled;

  UpdateMarketingPreferencesEvent({
    required this.promotionalEnabled,
    required this.newsletterEnabled,
  });

  @override
  List<Object?> get props => [promotionalEnabled, newsletterEnabled];
}

class ResetNotificationPreferencesEvent extends NotificationPreferencesEvent {}