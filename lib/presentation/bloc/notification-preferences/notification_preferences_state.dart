import 'package:equatable/equatable.dart';

import '../../../data/models/notification_preferences.dart';
import '../../../data/models/notification_templates.dart';

abstract class NotificationPreferencesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationPreferencesInitial extends NotificationPreferencesState {}

class NotificationPreferencesLoading extends NotificationPreferencesState {}

class NotificationPreferencesLoaded extends NotificationPreferencesState {
  final NotificationPreferences preferences;
  final NotificationTemplates? templates;

  NotificationPreferencesLoaded({
    required this.preferences,
    this.templates,
  });

  @override
  List<Object?> get props => [preferences, templates];

  NotificationPreferencesLoaded copyWith({
    NotificationPreferences? preferences,
    NotificationTemplates? templates,
  }) {
    return NotificationPreferencesLoaded(
      preferences: preferences ?? this.preferences,
      templates: templates ?? this.templates,
    );
  }
}

class NotificationTemplatesLoaded extends NotificationPreferencesState {
  final NotificationTemplates templates;

  NotificationTemplatesLoaded({required this.templates});

  @override
  List<Object?> get props => [templates];
}

class NotificationPreferencesUpdated extends NotificationPreferencesState {
  final NotificationPreferences preferences;

  NotificationPreferencesUpdated({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

class NotificationPreferencesError extends NotificationPreferencesState {
  final String message;

  NotificationPreferencesError({required this.message});

  @override
  List<Object?> get props => [message];
}