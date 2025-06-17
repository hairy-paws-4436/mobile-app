import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository}) : super(NotificationInitial()) {
    // Handlers originales
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllNotificationsAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);

    // Handlers para donaciones
    on<AcceptDonationEvent>(_onAcceptDonation);
    on<RejectDonationEvent>(_onRejectDonation);

    // Handlers para adopciones
    on<AcceptAdoptionEvent>(_onAcceptAdoption);
    on<RejectAdoptionEvent>(_onRejectAdoption);

    // Handlers para visitas
    on<AcceptVisitEvent>(_onAcceptVisit);
    on<RejectVisitEvent>(_onRejectVisit);
  }

  Future<void> _onFetchNotifications(
      FetchNotificationsEvent event,
      Emitter<NotificationState> emit,
      ) async {
    if (state is! NotificationsLoaded) {
      emit(NotificationLoading());
    }
    try {
      final notifications = await notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(
      MarkNotificationAsReadEvent event,
      Emitter<NotificationState> emit,
      ) async {
    try {
      await notificationRepository.markNotificationAsRead(event.notificationId);
      emit(NotificationMarkedAsRead());

      // Refresh notifications
      final notifications = await notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
      MarkAllNotificationsAsReadEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      await notificationRepository.markAllNotificationsAsRead();
      emit(AllNotificationsMarkedAsRead());

      // Refresh notifications
      final notifications = await notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onDeleteNotification(
      DeleteNotificationEvent event,
      Emitter<NotificationState> emit,
      ) async {
    try {
      await notificationRepository.deleteNotification(event.notificationId);
      emit(NotificationDeleted());

      // Refresh notifications
      final notifications = await notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  // =============== HANDLERS PARA DONACIONES ===============
  Future<void> _onAcceptDonation(
      AcceptDonationEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      await notificationRepository.acceptDonation(
        event.donationId,
        event.notes,
      );

      await notificationRepository.markNotificationAsRead(event.notificationId);
      emit(DonationAccepted());

      final notifications = await notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onRejectDonation(
      RejectDonationEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      await notificationRepository.rejectDonation(
        event.donationId,
        event.reason,
      );

      await notificationRepository.markNotificationAsRead(event.notificationId);
      emit(DonationRejected());

      final notifications = await notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  // =============== HANDLERS PARA ADOPCIONES ===============
  Future<void> _onAcceptAdoption(
      AcceptAdoptionEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      await notificationRepository.acceptAdoption(
        event.adoptionId,
        event.notes,
      );

      await notificationRepository.markNotificationAsRead(event.notificationId);
      emit(AdoptionAccepted());

      final notifications = await notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onRejectAdoption(
      RejectAdoptionEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      await notificationRepository.rejectAdoption(
        event.adoptionId,
        event.reason,
      );

      await notificationRepository.markNotificationAsRead(event.notificationId);
      emit(AdoptionRejected());

      final notifications = await notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  // =============== HANDLERS PARA VISITAS ===============
  Future<void> _onAcceptVisit(
      AcceptVisitEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      await notificationRepository.acceptVisit(
        event.visitId,
        event.notes,
      );

      await notificationRepository.markNotificationAsRead(event.notificationId);
      emit(VisitAccepted());

      final notifications = await notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onRejectVisit(
      RejectVisitEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      await notificationRepository.rejectVisit(
        event.visitId,
        event.reason,
      );

      await notificationRepository.markNotificationAsRead(event.notificationId);
      emit(VisitRejected());

      final notifications = await notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}