class GamificationBadge {
  final String badge;
  final int current;
  final int target;
  final double progress;

  GamificationBadge({
    required this.badge,
    required this.current,
    required this.target,
    required this.progress,
  });

  factory GamificationBadge.fromJson(Map<String, dynamic> json) {
    return GamificationBadge(
      badge: json['badge'] ?? '',
      current: json['current'] is int
          ? json['current']
          : int.tryParse(json['current']?.toString() ?? '0') ?? 0,
      target: json['target'] is int
          ? json['target']
          : int.tryParse(json['target']?.toString() ?? '0') ?? 0,
      progress: json['progress'] is double
          ? json['progress']
          : double.tryParse(json['progress']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

class BadgeDescription {
  final String name;
  final String description;
  final String icon;
  final int points;

  BadgeDescription({
    required this.name,
    required this.description,
    required this.icon,
    required this.points,
  });

  factory BadgeDescription.fromJson(Map<String, dynamic> json) {
    return BadgeDescription(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      points: json['points'] ?? 0,
    );
  }
}

class Achievement {
  final String badgeId;
  final String badgeName;
  final String description;
  final String icon;
  final int points;
  final DateTime earnedAt;

  Achievement({
    required this.badgeId,
    required this.badgeName,
    required this.description,
    required this.icon,
    required this.points,
    required this.earnedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      badgeId: json['badgeId'] ?? '',
      badgeName: json['badgeName'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      points: json['points'] ?? 0,
      earnedAt: DateTime.parse(json['earnedAt']),
    );
  }
}

class GamificationStats {
  final String id;
  final String ongId;
  final int totalPoints;
  final int monthlyPoints;
  final int weeklyPoints;
  final int currentLevel;
  final int pointsToNextLevel;
  final int globalRank;
  final int regionalRank;
  final int totalAdoptionsFacilitated;
  final int animalsPublished;
  final int eventsOrganized;
  final double donationsReceived;
  final int profileCompletionPercentage;
  final double? responseTimeHours;
  final double adoptionSuccessRate;
  final int currentStreakDays;
  final int longestStreakDays;
  final DateTime? lastActivityDate;
  final List<String> earnedBadges;
  final List<String>? featuredBadges;
  final int monthlyRecognitionCount;
  final int communityVotes;
  final int testimonialsReceived;
  final int? monthlyAdoptionGoal;
  final int monthlyAdoptionsCurrent;
  final double goalCompletionPercentage;
  final int partnerOngsCount;
  final int crossPromotionsCount;
  final int socialMediaMentions;
  final double volunteerHoursGenerated;
  final DateTime? lastPointsCalculation;
  final DateTime? weeklyResetDate;
  final DateTime? monthlyResetDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  GamificationStats({
    required this.id,
    required this.ongId,
    required this.totalPoints,
    required this.monthlyPoints,
    required this.weeklyPoints,
    required this.currentLevel,
    required this.pointsToNextLevel,
    required this.globalRank,
    required this.regionalRank,
    required this.totalAdoptionsFacilitated,
    required this.animalsPublished,
    required this.eventsOrganized,
    required this.donationsReceived,
    required this.profileCompletionPercentage,
    this.responseTimeHours,
    required this.adoptionSuccessRate,
    required this.currentStreakDays,
    required this.longestStreakDays,
    this.lastActivityDate,
    required this.earnedBadges,
    this.featuredBadges,
    required this.monthlyRecognitionCount,
    required this.communityVotes,
    required this.testimonialsReceived,
    this.monthlyAdoptionGoal,
    required this.monthlyAdoptionsCurrent,
    required this.goalCompletionPercentage,
    required this.partnerOngsCount,
    required this.crossPromotionsCount,
    required this.socialMediaMentions,
    required this.volunteerHoursGenerated,
    this.lastPointsCalculation,
    this.weeklyResetDate,
    this.monthlyResetDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GamificationStats.fromJson(Map<String, dynamic> json) {
    return GamificationStats(
      id: json['id'] ?? '',
      ongId: json['ongId'] ?? '',
      totalPoints: json['totalPoints'] ?? 0,
      monthlyPoints: json['monthlyPoints'] ?? 0,
      weeklyPoints: json['weeklyPoints'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      pointsToNextLevel: json['pointsToNextLevel'] ?? 0,
      globalRank: json['globalRank'] ?? 0,
      regionalRank: json['regionalRank'] ?? 0,
      totalAdoptionsFacilitated: json['totalAdoptionsFacilitated'] ?? 0,
      animalsPublished: json['animalsPublished'] ?? 0,
      eventsOrganized: json['eventsOrganized'] ?? 0,
      donationsReceived: double.tryParse(json['donationsReceived']?.toString() ?? '0.0') ?? 0.0,
      profileCompletionPercentage: json['profileCompletionPercentage'] ?? 0,
      responseTimeHours: json['responseTimeHours'] != null
          ? double.tryParse(json['responseTimeHours'].toString())
          : null,
      adoptionSuccessRate: double.tryParse(json['adoptionSuccessRate']?.toString() ?? '0.0') ?? 0.0,
      currentStreakDays: json['currentStreakDays'] ?? 0,
      longestStreakDays: json['longestStreakDays'] ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'])
          : null,
      earnedBadges: List<String>.from(json['earnedBadges'] ?? []),
      featuredBadges: json['featuredBadges'] != null
          ? List<String>.from(json['featuredBadges'])
          : null,
      monthlyRecognitionCount: json['monthlyRecognitionCount'] ?? 0,
      communityVotes: json['communityVotes'] ?? 0,
      testimonialsReceived: json['testimonialsReceived'] ?? 0,
      monthlyAdoptionGoal: json['monthlyAdoptionGoal'],
      monthlyAdoptionsCurrent: json['monthlyAdoptionsCurrent'] ?? 0,
      goalCompletionPercentage: double.tryParse(json['goalCompletionPercentage']?.toString() ?? '0.0') ?? 0.0,
      partnerOngsCount: json['partnerOngsCount'] ?? 0,
      crossPromotionsCount: json['crossPromotionsCount'] ?? 0,
      socialMediaMentions: json['socialMediaMentions'] ?? 0,
      volunteerHoursGenerated: double.tryParse(json['volunteerHoursGenerated']?.toString() ?? '0.0') ?? 0.0,
      lastPointsCalculation: json['lastPointsCalculation'] != null
          ? DateTime.parse(json['lastPointsCalculation'])
          : null,
      weeklyResetDate: json['weeklyResetDate'] != null
          ? DateTime.parse(json['weeklyResetDate'])
          : null,
      monthlyResetDate: json['monthlyResetDate'] != null
          ? DateTime.parse(json['monthlyResetDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class MyGamificationStats {
  final GamificationStats gamification;
  final List<Achievement> recentAchievements;
  final List<GamificationBadge> nextBadges;
  final RankingInfo rankingInfo;

  MyGamificationStats({
    required this.gamification,
    required this.recentAchievements,
    required this.nextBadges,
    required this.rankingInfo,
  });

  factory MyGamificationStats.fromJson(Map<String, dynamic> json) {
    return MyGamificationStats(
      gamification: GamificationStats.fromJson(json['gamification']),
      recentAchievements: (json['recentAchievements'] as List)
          .map((item) => Achievement.fromJson(item))
          .toList(),
      nextBadges: (json['nextBadges'] as List)
          .map((item) => GamificationBadge.fromJson(item))
          .toList(),
      rankingInfo: RankingInfo.fromJson(json['rankingInfo']),
    );
  }
}

class RankingInfo {
  final int globalRank;
  final int monthlyRank;
  final int totalOngs;

  RankingInfo({
    required this.globalRank,
    required this.monthlyRank,
    required this.totalOngs,
  });

  factory RankingInfo.fromJson(Map<String, dynamic> json) {
    return RankingInfo(
      globalRank: json['globalRank'] ?? 0,
      monthlyRank: json['monthlyRank'] ?? 0,
      totalOngs: json['totalOngs'] ?? 0,
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String ongId;
  final String ongName;
  final int points;
  final int level;
  final List<String> badges;
  final int adoptions;

  LeaderboardEntry({
    required this.rank,
    required this.ongId,
    required this.ongName,
    required this.points,
    required this.level,
    required this.badges,
    required this.adoptions,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      ongId: json['ongId'] ?? '',
      ongName: json['ongName'] ?? '',
      points: json['points'] ?? 0,
      level: json['level'] ?? 1,
      badges: List<String>.from(json['badges'] ?? []),
      adoptions: json['adoptions'] ?? 0,
    );
  }
}

class AvailableBadges {
  final List<GamificationBadge> nextBadges;
  final Map<String, BadgeDescription> allBadgeDescriptions;

  AvailableBadges({
    required this.nextBadges,
    required this.allBadgeDescriptions,
  });

  factory AvailableBadges.fromJson(Map<String, dynamic> json) {
    final descriptions = <String, BadgeDescription>{};
    if (json['allBadgeDescriptions'] != null) {
      json['allBadgeDescriptions'].forEach((key, value) {
        descriptions[key] = BadgeDescription.fromJson(value);
      });
    }

    return AvailableBadges(
      nextBadges: (json['nextBadges'] as List)
          .map((item) => GamificationBadge.fromJson(item))
          .toList(),
      allBadgeDescriptions: descriptions,
    );
  }
}

class TopPerformers {
  final List<LeaderboardEntry> monthlyTop;
  final List<LeaderboardEntry> allTimeTop;
  final String category;

  TopPerformers({
    required this.monthlyTop,
    required this.allTimeTop,
    required this.category,
  });

  factory TopPerformers.fromJson(Map<String, dynamic> json) {
    return TopPerformers(
      monthlyTop: (json['monthlyTop'] as List)
          .map((item) => LeaderboardEntry.fromJson(item))
          .toList(),
      allTimeTop: (json['allTimeTop'] as List)
          .map((item) => LeaderboardEntry.fromJson(item))
          .toList(),
      category: json['category'] ?? 'all',
    );
  }
}

class PublicGamificationProfile {
  final int level;
  final int totalPoints;
  final int totalAdoptions;
  final int eventsOrganized;
  final List<String> featuredBadges;
  final int monthlyRank;
  final int globalRank;
  final int currentStreak;

  PublicGamificationProfile({
    required this.level,
    required this.totalPoints,
    required this.totalAdoptions,
    required this.eventsOrganized,
    required this.featuredBadges,
    required this.monthlyRank,
    required this.globalRank,
    required this.currentStreak,
  });

  factory PublicGamificationProfile.fromJson(Map<String, dynamic> json) {
    return PublicGamificationProfile(
      level: json['level'] ?? 1,
      totalPoints: json['totalPoints'] ?? 0,
      totalAdoptions: json['totalAdoptions'] ?? 0,
      eventsOrganized: json['eventsOrganized'] ?? 0,
      featuredBadges: List<String>.from(json['featuredBadges'] ?? []),
      monthlyRank: json['monthlyRank'] ?? 0,
      globalRank: json['globalRank'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
    );
  }
}

class RecentAchievements {
  final List<Achievement> recentAchievements;

  RecentAchievements({required this.recentAchievements});

  factory RecentAchievements.fromJson(Map<String, dynamic> json) {
    return RecentAchievements(
      recentAchievements: (json['recentAchievements'] as List)
          .map((item) => Achievement.fromJson(item))
          .toList(),
    );
  }
}