import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/matching_repository.dart';
import 'matching_event.dart';
import 'matching_state.dart';

class MatchingBloc extends Bloc<MatchingEvent, MatchingState> {
  final MatchingRepository matchingRepository;

  MatchingBloc({required this.matchingRepository}) : super(MatchingInitial()) {
    on<CreateOrUpdatePreferencesEvent>(_onCreateOrUpdatePreferences);
    on<GetUserPreferencesEvent>(_onGetUserPreferences);
    on<GetPreferencesStatusEvent>(_onGetPreferencesStatus);
    on<CreateAnimalProfileEvent>(_onCreateAnimalProfile);
    on<GetAnimalProfileEvent>(_onGetAnimalProfile);
    on<GetRecommendationsEvent>(_onGetRecommendations);
    on<GetCompatibilityAnalysisEvent>(_onGetCompatibilityAnalysis);
    on<RefreshRecommendationsEvent>(_onRefreshRecommendations);
    on<ClearMatchingStateEvent>(_onClearMatchingState);
  }

  Future<void> _onCreateOrUpdatePreferences(
      CreateOrUpdatePreferencesEvent event,
      Emitter<MatchingState> emit,
      ) async {
    emit(MatchingLoading());
    try {
      final preferences = await matchingRepository.createOrUpdatePreferences(event.preferencesData);
      emit(PreferencesCreated(preferences));
    } catch (e) {
      emit(MatchingError(e.toString()));
    }
  }

  Future<void> _onGetUserPreferences(
      GetUserPreferencesEvent event,
      Emitter<MatchingState> emit,
      ) async {
    emit(MatchingLoading());
    try {
      final preferences = await matchingRepository.getUserPreferences();
      emit(PreferencesLoaded(
        preferences: preferences,
        hasPreferences: preferences != null,
        isComplete: preferences?.isComplete ?? false,
      ));
    } catch (e) {
      emit(MatchingError(e.toString()));
    }
  }

  Future<void> _onGetPreferencesStatus(
      GetPreferencesStatusEvent event,
      Emitter<MatchingState> emit,
      ) async {
    emit(MatchingLoading());
    try {
      final status = await matchingRepository.getPreferencesStatus();
      emit(PreferencesStatusLoaded(status));
    } catch (e) {
      emit(MatchingError(e.toString()));
    }
  }

  Future<void> _onCreateAnimalProfile(
      CreateAnimalProfileEvent event,
      Emitter<MatchingState> emit,
      ) async {
    emit(MatchingLoading());
    try {
      final profile = await matchingRepository.createAnimalProfile(
        event.animalId,
        event.profileData,
      );
      emit(AnimalProfileCreated(profile));
    } catch (e) {
      emit(MatchingError(e.toString()));
    }
  }

  Future<void> _onGetAnimalProfile(
      GetAnimalProfileEvent event,
      Emitter<MatchingState> emit,
      ) async {
    emit(MatchingLoading());
    try {
      final profile = await matchingRepository.getAnimalProfile(event.animalId);
      emit(AnimalProfileLoaded(
        profile: profile,
        hasProfile: profile != null,
      ));
    } catch (e) {
      emit(MatchingError(e.toString()));
    }
  }

  Future<void> _onGetRecommendations(
      GetRecommendationsEvent event,
      Emitter<MatchingState> emit,
      ) async {
    emit(MatchingLoading());
    try {
      final recommendations = await matchingRepository.getRecommendations(
        limit: event.limit,
        minScore: event.minScore,
        includeSpecialNeeds: event.includeSpecialNeeds,
      );
      emit(RecommendationsLoaded(recommendations));
    } catch (e) {
      emit(MatchingError(e.toString()));
    }
  }

  Future<void> _onGetCompatibilityAnalysis(
      GetCompatibilityAnalysisEvent event,
      Emitter<MatchingState> emit,
      ) async {
    emit(MatchingLoading());
    try {
      final analysis = await matchingRepository.getCompatibilityAnalysis(event.animalId);
      emit(CompatibilityAnalysisLoaded(analysis));
    } catch (e) {
      emit(MatchingError(e.toString()));
    }
  }

  Future<void> _onRefreshRecommendations(
      RefreshRecommendationsEvent event,
      Emitter<MatchingState> emit,
      ) async {
    try {
      final recommendations = await matchingRepository.getRecommendations();
      emit(RecommendationsLoaded(recommendations));
    } catch (e) {
      emit(MatchingError(e.toString()));
    }
  }

  Future<void> _onClearMatchingState(
      ClearMatchingStateEvent event,
      Emitter<MatchingState> emit,
      ) async {
    emit(MatchingInitial());
  }
}