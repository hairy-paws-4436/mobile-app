import 'package:equatable/equatable.dart';

abstract class MatchingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Preferences Events
class CreateOrUpdatePreferencesEvent extends MatchingEvent {
  final Map<String, dynamic> preferencesData;

  CreateOrUpdatePreferencesEvent({required this.preferencesData});

  @override
  List<Object?> get props => [preferencesData];
}

class GetUserPreferencesEvent extends MatchingEvent {}

class GetPreferencesStatusEvent extends MatchingEvent {}

// Animal Profile Events
class CreateAnimalProfileEvent extends MatchingEvent {
  final String animalId;
  final Map<String, dynamic> profileData;

  CreateAnimalProfileEvent({
    required this.animalId,
    required this.profileData,
  });

  @override
  List<Object?> get props => [animalId, profileData];
}

class GetAnimalProfileEvent extends MatchingEvent {
  final String animalId;

  GetAnimalProfileEvent({required this.animalId});

  @override
  List<Object?> get props => [animalId];
}

// Recommendations Events
class GetRecommendationsEvent extends MatchingEvent {
  final int? limit;
  final double? minScore;
  final bool? includeSpecialNeeds;

  GetRecommendationsEvent({
    this.limit,
    this.minScore,
    this.includeSpecialNeeds,
  });

  @override
  List<Object?> get props => [limit, minScore, includeSpecialNeeds];
}

class GetCompatibilityAnalysisEvent extends MatchingEvent {
  final String animalId;

  GetCompatibilityAnalysisEvent({required this.animalId});

  @override
  List<Object?> get props => [animalId];
}

class RefreshRecommendationsEvent extends MatchingEvent {}

class ClearMatchingStateEvent extends MatchingEvent {}