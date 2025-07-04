import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/post_adoption_repository.dart';
import 'post_adoption_event.dart';
import 'post_adoption_state.dart';

class PostAdoptionBloc extends Bloc<PostAdoptionEvent, PostAdoptionState> {
  final PostAdoptionRepository postAdoptionRepository;

  PostAdoptionBloc({required this.postAdoptionRepository}) : super(PostAdoptionInitial()) {
    // Adopter events
    on<GetMyFollowUpsEvent>(_onGetMyFollowUps);
    on<GetFollowUpDetailsEvent>(_onGetFollowUpDetails);
    on<ScheduleFollowUpsEvent>(_onScheduleFollowUps);
    on<CompleteFollowUpEvent>(_onCompleteFollowUp);
    on<SkipFollowUpEvent>(_onSkipFollowUp);

    // NGO events
    on<GetNGODashboardEvent>(_onGetNGODashboard);
    on<GetNGOAnalyticsEvent>(_onGetNGOAnalytics);
    on<GetAtRiskAdoptionsEvent>(_onGetAtRiskAdoptions);
    on<StartInterventionEvent>(_onStartIntervention);

    // Admin events
    on<GetAdminStatsEvent>(_onGetAdminStats);
    on<SendRemindersEvent>(_onSendReminders);

    // UI events
    on<RefreshPostAdoptionDataEvent>(_onRefreshPostAdoptionData);
    on<ClearPostAdoptionStateEvent>(_onClearPostAdoptionState);
  }

  // Adopter event handlers
  Future<void> _onGetMyFollowUps(
      GetMyFollowUpsEvent event,
      Emitter<PostAdoptionState> emit,
      ) async {
    emit(PostAdoptionLoading());
    try {
      final followUps = await postAdoptionRepository.getMyFollowUps(status: event.status);
      emit(MyFollowUpsLoaded(followUps));
    } catch (e) {
      emit(PostAdoptionError(e.toString()));
    }
  }

  Future<void> _onGetFollowUpDetails(
      GetFollowUpDetailsEvent event,
      Emitter<PostAdoptionState> emit,
      ) async {
    emit(PostAdoptionLoading());
    try {
      final followUp = await postAdoptionRepository.getFollowUpDetails(event.followupId);
      emit(FollowUpDetailsLoaded(followUp));
    } catch (e) {
      emit(PostAdoptionError(e.toString()));
    }
  }

  Future<void> _onScheduleFollowUps(
      ScheduleFollowUpsEvent event,
      Emitter<PostAdoptionState> emit,
      ) async {
    emit(PostAdoptionLoading());
    try {
      await postAdoptionRepository.scheduleFollowUps(event.adoptionId);
      emit(FollowUpsScheduled(event.adoptionId));
    } catch (e) {
      emit(PostAdoptionError(e.toString()));
    }
  }

  Future<void> _onCompleteFollowUp(
      CompleteFollowUpEvent event,
      Emitter<PostAdoptionState> emit,
      ) async {
    emit(PostAdoptionLoading());
    try {
      await postAdoptionRepository.completeFollowUp(event.followupId, event.formData);
      emit(FollowUpCompleted(event.followupId));
    } catch (e) {
      emit(PostAdoptionError(e.toString()));
    }
  }

  Future<void> _onSkipFollowUp(
      SkipFollowUpEvent event,
      Emitter<PostAdoptionState> emit,
      ) async {
    emit(PostAdoptionLoading());
    try {
      await postAdoptionRepository.skipFollowUp(event.followupId);
      emit(FollowUpSkipped(event.followupId));
    } catch (e) {
      emit(PostAdoptionError(e.toString()));
    }
  }

  // NGO event handlers
  Future<void> _onGetNGODashboard(
      GetNGODashboardEvent event,
      Emitter<PostAdoptionState> emit,
      ) async {
    emit(PostAdoptionLoading());
    try {
      final dashboard = await postAdoptionRepository.getNGODashboard();
      emit(NGODashboardLoaded(dashboard));
    } catch (e) {
      emit(PostAdoptionError(e.toString()));
    }
  }

  Future<void> _onGetNGOAnalytics(
      GetNGOAnalyticsEvent event,
      Emitter<PostAdoptionState> emit,
      ) async {
    emit(PostAdoptionLoading());
    try {
      final analytics = await postAdoptionRepository.getNGOAnalytics(period: event.period);
      emit(NGOAnalyticsLoaded(analytics));
    } catch (e) {
      emit(PostAdoptionError(e.toString()));
    }
  }

  Future<void> _onGetAtRiskAdoptions(
      GetAtRiskAdoptionsEvent event,
      Emitter<PostAdoptionState> emit,
      ) async {
    emit(PostAdoptionLoading());
    try {
      final atRiskAdoptions = await postAdoptionRepository.getAtRiskAdoptions();
      emit(AtRiskAdoptionsLoaded(atRiskAdoptions));
    } catch (e) {
      emit(PostAdoptionError(e.toString()));
    }
  }

  Future<void> _onStartIntervention(
      StartInterventionEvent event,
      Emitter<PostAdoptionState> emit,
      ) async {
    emit(PostAdoptionLoading());
    try {
      await postAdoptionRepository.startIntervention(event.followupId);
      emit(InterventionStarted(event.followupId));
    } catch (e) {
      emit(PostAdoptionError(e.toString()));
    }
  }

  // Admin event handlers
  Future<void> _onGetAdminStats(
      GetAdminStatsEvent event,
      Emitter<PostAdoptionState> emit,
      ) async {
    emit(PostAdoptionLoading());
    try {
      final stats = await postAdoptionRepository.getAdminStats();
      emit(AdminStatsLoaded(stats));
    } catch (e) {
      emit(PostAdoptionError(e.toString()));
    }
  }

  Future<void> _onSendReminders(
      SendRemindersEvent event,
      Emitter<PostAdoptionState> emit,
      ) async {
    emit(PostAdoptionLoading());
    try {
      await postAdoptionRepository.sendReminders();
      emit(RemindersSent());
    } catch (e) {
      emit(PostAdoptionError(e.toString()));
    }
  }

  // UI event handlers
  Future<void> _onRefreshPostAdoptionData(
      RefreshPostAdoptionDataEvent event,
      Emitter<PostAdoptionState> emit,
      ) async {
    // This can be used to refresh current data based on current state
    if (state is MyFollowUpsLoaded) {
      add(GetMyFollowUpsEvent());
    } else if (state is NGODashboardLoaded) {
      add(GetNGODashboardEvent());
    } else if (state is AtRiskAdoptionsLoaded) {
      add(GetAtRiskAdoptionsEvent());
    }
  }

  Future<void> _onClearPostAdoptionState(
      ClearPostAdoptionStateEvent event,
      Emitter<PostAdoptionState> emit,
      ) async {
    emit(PostAdoptionInitial());
  }
}