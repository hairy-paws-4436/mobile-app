import 'package:equatable/equatable.dart';

import '../../../data/models/animal_profile.dart';
import '../../../data/models/recommendation.dart';
import '../../../data/models/user_preferences.dart';

abstract class MatchingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MatchingInitial extends MatchingState {}

class MatchingLoading extends MatchingState {}

// Preferences States
class PreferencesLoaded extends MatchingState {
  final UserPreferences? preferences;
  final bool hasPreferences;
  final bool isComplete;

  PreferencesLoaded({
    this.preferences,
    required this.hasPreferences,
    required this.isComplete,
  });

  @override
  List<Object?> get props => [preferences, hasPreferences, isComplete];
}

class PreferencesCreated extends MatchingState {
  final UserPreferences preferences;

  PreferencesCreated(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class PreferencesStatusLoaded extends MatchingState {
  final PreferencesStatus status;

  PreferencesStatusLoaded(this.status);

  @override
  List<Object?> get props => [status];
}

// Animal Profile States
class AnimalProfileLoaded extends MatchingState {
  final AnimalProfile? profile;
  final bool hasProfile;

  AnimalProfileLoaded({
    this.profile,
    required this.hasProfile,
  });

  @override
  List<Object?> get props => [profile, hasProfile];
}

class AnimalProfileCreated extends MatchingState {
  final AnimalProfile profile;

  AnimalProfileCreated(this.profile);

  @override
  List<Object?> get props => [profile];
}

// Recommendations States
class RecommendationsLoaded extends MatchingState {
  final RecommendationsResponse recommendations;

  RecommendationsLoaded(this.recommendations);

  @override
  List<Object?> get props => [recommendations];
}

class CompatibilityAnalysisLoaded extends MatchingState {
  final CompatibilityAnalysis analysis;

  CompatibilityAnalysisLoaded(this.analysis);

  @override
  List<Object?> get props => [analysis];
}

class MatchingError extends MatchingState {
  final String message;

  MatchingError(this.message);

  @override
  List<Object?> get props => [message];
}