import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/notification_preferences_repository.dart';
import 'notification_preferences_event.dart';
import 'notification_preferences_state.dart';

class NotificationPreferencesBloc extends Bloc<NotificationPreferencesEvent, NotificationPreferencesState> {
  final NotificationPreferencesRepository notificationPreferencesRepository;

  NotificationPreferencesBloc({required this.notificationPreferencesRepository})
      : super(NotificationPreferencesInitial()) {
    on<LoadNotificationPreferencesEvent>(_onLoadNotificationPreferences);
    on<LoadNotificationTemplatesEvent>(_onLoadNotificationTemplates);
    on<UpdateNotificationPreferencesEvent>(_onUpdateNotificationPreferences);
    on<ApplyNotificationTemplateEvent>(_onApplyNotificationTemplate);
    on<UpdateGlobalNotificationsEvent>(_onUpdateGlobalNotifications);
    on<UpdateQuietHoursEvent>(_onUpdateQuietHours);
    on<UpdatePreferredChannelsEvent>(_onUpdatePreferredChannels);
    on<UpdateAdoptionNotificationsEvent>(_onUpdateAdoptionNotifications);
    on<UpdateMatchingNotificationsEvent>(_onUpdateMatchingNotifications);
    on<UpdateEventNotificationsEvent>(_onUpdateEventNotifications);
    on<UpdateFilteringPreferencesEvent>(_onUpdateFilteringPreferences);
    on<UpdateMarketingPreferencesEvent>(_onUpdateMarketingPreferences);
    on<ResetNotificationPreferencesEvent>(_onResetNotificationPreferences);
  }

  Future<void> _onLoadNotificationPreferences(
      LoadNotificationPreferencesEvent event,
      Emitter<NotificationPreferencesState> emit,
      ) async {
    emit(NotificationPreferencesLoading());
    try {
      final preferences = await notificationPreferencesRepository.getNotificationPreferences();
      emit(NotificationPreferencesLoaded(preferences: preferences));
    } catch (e) {
      emit(NotificationPreferencesError(message: e.toString()));
    }
  }

  Future<void> _onLoadNotificationTemplates(
      LoadNotificationTemplatesEvent event,
      Emitter<NotificationPreferencesState> emit,
      ) async {
    try {
      final templates = await notificationPreferencesRepository.getNotificationTemplates();

      if (state is NotificationPreferencesLoaded) {
        final currentState = state as NotificationPreferencesLoaded;
        emit(currentState.copyWith(templates: templates));
      } else {
        emit(NotificationTemplatesLoaded(templates: templates));
      }
    } catch (e) {
      emit(NotificationPreferencesError(message: e.toString()));
    }
  }

  Future<void> _onUpdateNotificationPreferences(
      UpdateNotificationPreferencesEvent event,
      Emitter<NotificationPreferencesState> emit,
      ) async {
    emit(NotificationPreferencesLoading());
    try {
      final updatedPreferences = await notificationPreferencesRepository.updateNotificationPreferences(
        event.preferences,
      );
      emit(NotificationPreferencesUpdated(preferences: updatedPreferences));
      emit(NotificationPreferencesLoaded(preferences: updatedPreferences));
    } catch (e) {
      emit(NotificationPreferencesError(message: e.toString()));
    }
  }

  Future<void> _onApplyNotificationTemplate(
      ApplyNotificationTemplateEvent event,
      Emitter<NotificationPreferencesState> emit,
      ) async {
    emit(NotificationPreferencesLoading());
    try {
      final updatedPreferences = await notificationPreferencesRepository.applyTemplate(
        event.templateName,
      );
      emit(NotificationPreferencesUpdated(preferences: updatedPreferences));
      emit(NotificationPreferencesLoaded(preferences: updatedPreferences));
    } catch (e) {
      emit(NotificationPreferencesError(message: e.toString()));
    }
  }

  Future<void> _onUpdateGlobalNotifications(
      UpdateGlobalNotificationsEvent event,
      Emitter<NotificationPreferencesState> emit,
      ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        globalNotificationsEnabled: event.enabled,
      );

      try {
        final savedPreferences = await notificationPreferencesRepository.updateNotificationPreferences(
          updatedPreferences.toJson(),
        );
        emit(currentState.copyWith(preferences: savedPreferences));
      } catch (e) {
        emit(NotificationPreferencesError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateQuietHours(
      UpdateQuietHoursEvent event,
      Emitter<NotificationPreferencesState> emit,
      ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        quietHoursEnabled: event.enabled,
        quietHoursStart: event.startTime ?? currentState.preferences.quietHoursStart,
        quietHoursEnd: event.endTime ?? currentState.preferences.quietHoursEnd,
      );

      try {
        final savedPreferences = await notificationPreferencesRepository.updateNotificationPreferences(
          updatedPreferences.toJson(),
        );
        emit(currentState.copyWith(preferences: savedPreferences));
      } catch (e) {
        emit(NotificationPreferencesError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdatePreferredChannels(
      UpdatePreferredChannelsEvent event,
      Emitter<NotificationPreferencesState> emit,
      ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        preferredChannels: event.channels,
      );

      try {
        final savedPreferences = await notificationPreferencesRepository.updateNotificationPreferences(
          updatedPreferences.toJson(),
        );
        emit(currentState.copyWith(preferences: savedPreferences));
      } catch (e) {
        emit(NotificationPreferencesError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateAdoptionNotifications(
      UpdateAdoptionNotificationsEvent event,
      Emitter<NotificationPreferencesState> emit,
      ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        adoptionRequestsEnabled: event.requestsEnabled,
        adoptionRequestsFrequency: event.requestsFrequency,
        adoptionStatusEnabled: event.statusEnabled,
        adoptionStatusFrequency: event.statusFrequency,
      );

      try {
        final savedPreferences = await notificationPreferencesRepository.updateNotificationPreferences(
          updatedPreferences.toJson(),
        );
        emit(currentState.copyWith(preferences: savedPreferences));
      } catch (e) {
        emit(NotificationPreferencesError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateMatchingNotifications(
      UpdateMatchingNotificationsEvent event,
      Emitter<NotificationPreferencesState> emit,
      ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        newMatchesEnabled: event.newMatchesEnabled,
        newMatchesFrequency: event.newMatchesFrequency,
        newAnimalsEnabled: event.newAnimalsEnabled,
        newAnimalsFrequency: event.newAnimalsFrequency,
      );

      try {
        final savedPreferences = await notificationPreferencesRepository.updateNotificationPreferences(
          updatedPreferences.toJson(),
        );
        emit(currentState.copyWith(preferences: savedPreferences));
      } catch (e) {
        emit(NotificationPreferencesError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateEventNotifications(
      UpdateEventNotificationsEvent event,
      Emitter<NotificationPreferencesState> emit,
      ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        eventRemindersEnabled: event.eventRemindersEnabled,
        eventRemindersFrequency: event.eventRemindersFrequency,
        newEventsEnabled: event.newEventsEnabled,
        newEventsFrequency: event.newEventsFrequency,
      );

      try {
        final savedPreferences = await notificationPreferencesRepository.updateNotificationPreferences(
          updatedPreferences.toJson(),
        );
        emit(currentState.copyWith(preferences: savedPreferences));
      } catch (e) {
        emit(NotificationPreferencesError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateFilteringPreferences(
      UpdateFilteringPreferencesEvent event,
      Emitter<NotificationPreferencesState> emit,
      ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        preferredAnimalTypesForNotifications: event.preferredAnimalTypes,
        maxDistanceNotificationsKm: event.maxDistanceKm,
        onlyHighCompatibility: event.onlyHighCompatibility,
      );

      try {
        final savedPreferences = await notificationPreferencesRepository.updateNotificationPreferences(
          updatedPreferences.toJson(),
        );
        emit(currentState.copyWith(preferences: savedPreferences));
      } catch (e) {
        emit(NotificationPreferencesError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateMarketingPreferences(
      UpdateMarketingPreferencesEvent event,
      Emitter<NotificationPreferencesState> emit,
      ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        promotionalEnabled: event.promotionalEnabled,
        newsletterEnabled: event.newsletterEnabled,
      );

      try {
        final savedPreferences = await notificationPreferencesRepository.updateNotificationPreferences(
          updatedPreferences.toJson(),
        );
        emit(currentState.copyWith(preferences: savedPreferences));
      } catch (e) {
        emit(NotificationPreferencesError(message: e.toString()));
      }
    }
  }

  Future<void> _onResetNotificationPreferences(
      ResetNotificationPreferencesEvent event,
      Emitter<NotificationPreferencesState> emit,
      ) async {
    emit(NotificationPreferencesLoading());
    try {
      // Apply the "balanced" template as default reset
      final updatedPreferences = await notificationPreferencesRepository.applyTemplate('balanced');
      emit(NotificationPreferencesLoaded(preferences: updatedPreferences));
    } catch (e) {
      emit(NotificationPreferencesError(message: e.toString()));
    }
  }
}