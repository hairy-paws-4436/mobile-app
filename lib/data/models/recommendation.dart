import 'animal.dart';

class CompatibilityScore {
  final int overall;
  final int personality;
  final int lifestyle;
  final int experience;
  final int practical;

  CompatibilityScore({
    required this.overall,
    required this.personality,
    required this.lifestyle,
    required this.experience,
    required this.practical,
  });

  factory CompatibilityScore.fromJson(Map<String, dynamic> json) {
    return CompatibilityScore(
      overall: json['overall'] ?? 0,
      personality: json['personality'] ?? 0,
      lifestyle: json['lifestyle'] ?? 0,
      experience: json['experience'] ?? 0,
      practical: json['practical'] ?? 0,
    );
  }
}

class AnimalRecommendation {
  final Animal animal;
  final CompatibilityScore compatibility;
  final double score;
  final List<String> matchReasons;
  final List<String> concerns;

  AnimalRecommendation({
    required this.animal,
    required this.compatibility,
    required this.score,
    required this.matchReasons,
    required this.concerns,
  });

  factory AnimalRecommendation.fromJson(Map<String, dynamic> json) {
    return AnimalRecommendation(
      animal: Animal.fromJson(json['animal']),
      compatibility: CompatibilityScore.fromJson(json['compatibility']),
      score: json['score'] is double
          ? json['score']
          : double.tryParse(json['score']?.toString() ?? '0.0') ?? 0.0,
      matchReasons: List<String>.from(json['matchReasons'] ?? []),
      concerns: List<String>.from(json['concerns'] ?? []),
    );
  }
}

class RecommendationsResponse {
  final bool needsOnboarding;
  final int totalMatches;
  final List<AnimalRecommendation> recommendations;

  RecommendationsResponse({
    required this.needsOnboarding,
    required this.totalMatches,
    required this.recommendations,
  });

  factory RecommendationsResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationsResponse(
      needsOnboarding: json['needsOnboarding'] ?? false,
      totalMatches: json['totalMatches'] ?? 0,
      recommendations: (json['recommendations'] as List)
          .map((item) => AnimalRecommendation.fromJson(item))
          .toList(),
    );
  }
}

class CompatibilityAnalysis {
  final bool found;
  final CompatibilityScore compatibility;
  final double score;
  final List<String> matchReasons;
  final List<String> concerns;
  final String recommendation;

  CompatibilityAnalysis({
    required this.found,
    required this.compatibility,
    required this.score,
    required this.matchReasons,
    required this.concerns,
    required this.recommendation,
  });

  factory CompatibilityAnalysis.fromJson(Map<String, dynamic> json) {
    return CompatibilityAnalysis(
      found: json['found'] ?? false,
      compatibility: CompatibilityScore.fromJson(json['compatibility']),
      score: json['score'] is double
          ? json['score']
          : double.tryParse(json['score']?.toString() ?? '0.0') ?? 0.0,
      matchReasons: List<String>.from(json['matchReasons'] ?? []),
      concerns: List<String>.from(json['concerns'] ?? []),
      recommendation: json['recommendation'] ?? '',
    );
  }
}

class PreferencesStatus {
  final bool hasCompletedPreferences;
  final bool needsOnboarding;

  PreferencesStatus({
    required this.hasCompletedPreferences,
    required this.needsOnboarding,
  });

  factory PreferencesStatus.fromJson(Map<String, dynamic> json) {
    return PreferencesStatus(
      hasCompletedPreferences: json['hasCompletedPreferences'] ?? false,
      needsOnboarding: json['needsOnboarding'] ?? false,
    );
  }
}