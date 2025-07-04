class UserPreferences {
  final String id;
  final String userId;
  final List<String> preferredAnimalTypes;
  final List<String> preferredGenders;
  final int minAge;
  final int maxAge;
  final double minSize;
  final double maxSize;
  final String experienceLevel;
  final List<String> previousPetTypes;
  final String housingType;
  final String familyComposition;
  final bool hasOtherPets;
  final String otherPetsDescription;
  final String timeAvailability;
  final String preferredActivityLevel;
  final String workSchedule;
  final bool prefersTrained;
  final bool acceptsSpecialNeeds;
  final bool prefersVaccinated;
  final bool prefersSterilized;
  final int maxDistanceKm;
  final double latitude;
  final double longitude;
  final double monthlyBudget;
  final String adoptionReason;
  final String lifestyleDescription;
  final bool isComplete;
  final DateTime? completionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.id,
    required this.userId,
    required this.preferredAnimalTypes,
    required this.preferredGenders,
    required this.minAge,
    required this.maxAge,
    required this.minSize,
    required this.maxSize,
    required this.experienceLevel,
    required this.previousPetTypes,
    required this.housingType,
    required this.familyComposition,
    required this.hasOtherPets,
    required this.otherPetsDescription,
    required this.timeAvailability,
    required this.preferredActivityLevel,
    required this.workSchedule,
    required this.prefersTrained,
    required this.acceptsSpecialNeeds,
    required this.prefersVaccinated,
    required this.prefersSterilized,
    required this.maxDistanceKm,
    required this.latitude,
    required this.longitude,
    required this.monthlyBudget,
    required this.adoptionReason,
    required this.lifestyleDescription,
    required this.isComplete,
    this.completionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      preferredAnimalTypes: List<String>.from(json['preferredAnimalTypes'] ?? []),
      preferredGenders: List<String>.from(json['preferredGenders'] ?? []),
      minAge: json['minAge'] is int
          ? json['minAge']
          : int.tryParse(json['minAge']?.toString() ?? '0') ?? 0,
      maxAge: json['maxAge'] is int
          ? json['maxAge']
          : int.tryParse(json['maxAge']?.toString() ?? '0') ?? 0,
      minSize: json['minSize'] is double
          ? json['minSize']
          : double.tryParse(json['minSize']?.toString() ?? '0.0') ?? 0.0,
      maxSize: json['maxSize'] is double
          ? json['maxSize']
          : double.tryParse(json['maxSize']?.toString() ?? '0.0') ?? 0.0,
      experienceLevel: json['experienceLevel'] ?? '',
      previousPetTypes: List<String>.from(json['previousPetTypes'] ?? []),
      housingType: json['housingType'] ?? '',
      familyComposition: json['familyComposition'] ?? '',
      hasOtherPets: json['hasOtherPets'] ?? false,
      otherPetsDescription: json['otherPetsDescription'] ?? '',
      timeAvailability: json['timeAvailability'] ?? '',
      preferredActivityLevel: json['preferredActivityLevel'] ?? '',
      workSchedule: json['workSchedule'] ?? '',
      prefersTrained: json['prefersTrained'] ?? false,
      acceptsSpecialNeeds: json['acceptsSpecialNeeds'] ?? false,
      prefersVaccinated: json['prefersVaccinated'] ?? false,
      prefersSterilized: json['prefersSterilized'] ?? false,
      maxDistanceKm: json['maxDistanceKm'] is int
          ? json['maxDistanceKm']
          : int.tryParse(json['maxDistanceKm']?.toString() ?? '0') ?? 0,
      latitude: json['latitude'] is double
          ? json['latitude']
          : double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
      longitude: json['longitude'] is double
          ? json['longitude']
          : double.tryParse(json['longitude']?.toString() ?? '0.0') ?? 0.0,
      monthlyBudget: json['monthlyBudget'] is double
          ? json['monthlyBudget']
          : double.tryParse(json['monthlyBudget']?.toString() ?? '0.0') ?? 0.0,
      adoptionReason: json['adoptionReason'] ?? '',
      lifestyleDescription: json['lifestyleDescription'] ?? '',
      isComplete: json['isComplete'] ?? false,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredAnimalTypes': preferredAnimalTypes,
      'preferredGenders': preferredGenders,
      'minAge': minAge,
      'maxAge': maxAge,
      'minSize': minSize,
      'maxSize': maxSize,
      'experienceLevel': experienceLevel,
      'previousPetTypes': previousPetTypes,
      'housingType': housingType,
      'familyComposition': familyComposition,
      'hasOtherPets': hasOtherPets,
      'otherPetsDescription': otherPetsDescription,
      'timeAvailability': timeAvailability,
      'preferredActivityLevel': preferredActivityLevel,
      'workSchedule': workSchedule,
      'prefersTrained': prefersTrained,
      'acceptsSpecialNeeds': acceptsSpecialNeeds,
      'prefersVaccinated': prefersVaccinated,
      'prefersSterilized': prefersSterilized,
      'maxDistanceKm': maxDistanceKm,
      'latitude': latitude,
      'longitude': longitude,
      'monthlyBudget': monthlyBudget,
      'adoptionReason': adoptionReason,
      'lifestyleDescription': lifestyleDescription,
    };
  }
}