class AnimalProfile {
  final String id;
  final String animalId;
  final String energyLevel;
  final String socialLevel;
  final bool goodWithKids;
  final bool goodWithOtherPets;
  final bool goodWithStrangers;
  final String trainingLevel;
  final bool houseTrained;
  final bool leashTrained;
  final List<String> knownCommands;
  final String careLevel;
  final String exerciseNeeds;
  final String groomingNeeds;
  final bool specialDiet;
  final String dietDescription;
  final List<String> chronicConditions;
  final List<String> medications;
  final List<String> allergies;
  final String veterinaryNeeds;
  final bool destructiveBehavior;
  final bool separationAnxiety;
  final bool noiseSensitivity;
  final bool escapeTendency;
  final String idealHomeType;
  final String spaceRequirements;
  final List<String> climatePreferences;
  final String rescueStory;
  final String previousHomeExperience;
  final String behavioralNotes;
  final bool beginnerFriendly;
  final bool apartmentSuitable;
  final bool familyFriendly;
  final DateTime createdAt;
  final DateTime updatedAt;

  AnimalProfile({
    required this.id,
    required this.animalId,
    required this.energyLevel,
    required this.socialLevel,
    required this.goodWithKids,
    required this.goodWithOtherPets,
    required this.goodWithStrangers,
    required this.trainingLevel,
    required this.houseTrained,
    required this.leashTrained,
    required this.knownCommands,
    required this.careLevel,
    required this.exerciseNeeds,
    required this.groomingNeeds,
    required this.specialDiet,
    required this.dietDescription,
    required this.chronicConditions,
    required this.medications,
    required this.allergies,
    required this.veterinaryNeeds,
    required this.destructiveBehavior,
    required this.separationAnxiety,
    required this.noiseSensitivity,
    required this.escapeTendency,
    required this.idealHomeType,
    required this.spaceRequirements,
    required this.climatePreferences,
    required this.rescueStory,
    required this.previousHomeExperience,
    required this.behavioralNotes,
    required this.beginnerFriendly,
    required this.apartmentSuitable,
    required this.familyFriendly,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnimalProfile.fromJson(Map<String, dynamic> json) {
    return AnimalProfile(
      id: json['id'] ?? '',
      animalId: json['animalId'] ?? '',
      energyLevel: json['energyLevel'] ?? '',
      socialLevel: json['socialLevel'] ?? '',
      goodWithKids: json['goodWithKids'] ?? false,
      goodWithOtherPets: json['goodWithOtherPets'] ?? false,
      goodWithStrangers: json['goodWithStrangers'] ?? false,
      trainingLevel: json['trainingLevel'] ?? '',
      houseTrained: json['houseTrained'] ?? false,
      leashTrained: json['leashTrained'] ?? false,
      knownCommands: List<String>.from(json['knownCommands'] ?? []),
      careLevel: json['careLevel'] ?? '',
      exerciseNeeds: json['exerciseNeeds'] ?? '',
      groomingNeeds: json['groomingNeeds'] ?? '',
      specialDiet: json['specialDiet'] ?? false,
      dietDescription: json['dietDescription'] ?? '',
      chronicConditions: List<String>.from(json['chronicConditions'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      veterinaryNeeds: json['veterinaryNeeds'] ?? '',
      destructiveBehavior: json['destructiveBehavior'] ?? false,
      separationAnxiety: json['separationAnxiety'] ?? false,
      noiseSensitivity: json['noiseSensitivity'] ?? false,
      escapeTendency: json['escapeTendency'] ?? false,
      idealHomeType: json['idealHomeType'] ?? '',
      spaceRequirements: json['spaceRequirements'] ?? '',
      climatePreferences: List<String>.from(json['climatePreferences'] ?? []),
      rescueStory: json['rescueStory'] ?? '',
      previousHomeExperience: json['previousHomeExperience'] ?? '',
      behavioralNotes: json['behavioralNotes'] ?? '',
      beginnerFriendly: json['beginnerFriendly'] ?? false,
      apartmentSuitable: json['apartmentSuitable'] ?? false,
      familyFriendly: json['familyFriendly'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'energyLevel': energyLevel,
      'socialLevel': socialLevel,
      'goodWithKids': goodWithKids,
      'goodWithOtherPets': goodWithOtherPets,
      'goodWithStrangers': goodWithStrangers,
      'trainingLevel': trainingLevel,
      'houseTrained': houseTrained,
      'leashTrained': leashTrained,
      'knownCommands': knownCommands,
      'careLevel': careLevel,
      'exerciseNeeds': exerciseNeeds,
      'groomingNeeds': groomingNeeds,
      'specialDiet': specialDiet,
      'dietDescription': dietDescription,
      'chronicConditions': chronicConditions,
      'medications': medications,
      'allergies': allergies,
      'veterinaryNeeds': veterinaryNeeds,
      'destructiveBehavior': destructiveBehavior,
      'separationAnxiety': separationAnxiety,
      'noiseSensitivity': noiseSensitivity,
      'escapeTendency': escapeTendency,
      'idealHomeType': idealHomeType,
      'spaceRequirements': spaceRequirements,
      'climatePreferences': climatePreferences,
      'rescueStory': rescueStory,
      'previousHomeExperience': previousHomeExperience,
      'behavioralNotes': behavioralNotes,
      'beginnerFriendly': beginnerFriendly,
      'apartmentSuitable': apartmentSuitable,
      'familyFriendly': familyFriendly,
    };
  }
}