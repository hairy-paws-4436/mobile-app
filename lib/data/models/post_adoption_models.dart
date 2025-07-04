import 'animal.dart';
import 'user.dart';

class PostAdoptionFollowUp {
  final String id;
  final String adoptionId;
  final String adopterId;
  final String followUpType;
  final String status;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String? adaptationLevel;
  final bool? eatingWell;
  final bool? sleepingWell;
  final bool? usingBathroomProperly;
  final bool? showingAffection;
  final List<String>? behavioralIssues;
  final List<String>? healthConcerns;
  final bool? vetVisitScheduled;
  final DateTime? vetVisitDate;
  final int? satisfactionScore;
  final bool? wouldRecommend;
  final String? additionalComments;
  final bool needsSupport;
  final List<String>? supportType;
  final bool followUpRequired;
  final String riskLevel;
  final bool reminderSent;
  final int reminderCount;
  final DateTime? lastReminderDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Adoption? adoption;
  final User? adopter;

  PostAdoptionFollowUp({
    required this.id,
    required this.adoptionId,
    required this.adopterId,
    required this.followUpType,
    required this.status,
    required this.scheduledDate,
    this.completedDate,
    this.adaptationLevel,
    this.eatingWell,
    this.sleepingWell,
    this.usingBathroomProperly,
    this.showingAffection,
    this.behavioralIssues,
    this.healthConcerns,
    this.vetVisitScheduled,
    this.vetVisitDate,
    this.satisfactionScore,
    this.wouldRecommend,
    this.additionalComments,
    required this.needsSupport,
    this.supportType,
    required this.followUpRequired,
    required this.riskLevel,
    required this.reminderSent,
    required this.reminderCount,
    this.lastReminderDate,
    required this.createdAt,
    required this.updatedAt,
    this.adoption,
    this.adopter,
  });

  factory PostAdoptionFollowUp.fromJson(Map<String, dynamic> json) {
    return PostAdoptionFollowUp(
      id: json['id'] ?? '',
      adoptionId: json['adoptionId'] ?? '',
      adopterId: json['adopterId'] ?? '',
      followUpType: json['followUpType'] ?? '',
      status: json['status'] ?? '',
      scheduledDate: DateTime.parse(json['scheduledDate']),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      adaptationLevel: json['adaptationLevel'],
      eatingWell: json['eatingWell'],
      sleepingWell: json['sleepingWell'],
      usingBathroomProperly: json['usingBathroomProperly'],
      showingAffection: json['showingAffection'],
      behavioralIssues: json['behavioralIssues'] != null
          ? List<String>.from(json['behavioralIssues'])
          : null,
      healthConcerns: json['healthConcerns'] != null
          ? List<String>.from(json['healthConcerns'])
          : null,
      vetVisitScheduled: json['vetVisitScheduled'],
      vetVisitDate: json['vetVisitDate'] != null
          ? DateTime.parse(json['vetVisitDate'])
          : null,
      satisfactionScore: json['satisfactionScore'],
      wouldRecommend: json['wouldRecommend'],
      additionalComments: json['additionalComments'],
      needsSupport: json['needsSupport'] ?? false,
      supportType: json['supportType'] != null
          ? List<String>.from(json['supportType'])
          : null,
      followUpRequired: json['followUpRequired'] ?? false,
      riskLevel: json['riskLevel'] ?? 'low',
      reminderSent: json['reminderSent'] ?? false,
      reminderCount: json['reminderCount'] ?? 0,
      lastReminderDate: json['lastReminderDate'] != null
          ? DateTime.parse(json['lastReminderDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      adoption: json['adoption'] != null
          ? Adoption.fromJson(json['adoption'])
          : null,
      adopter: json['adopter'] != null
          ? User.fromJson(json['adopter'])
          : null,
    );
  }
}

class Adoption {
  final String id;
  final String animalId;
  final String ownerId;
  final String adopterId;
  final String type;
  final String status;
  final DateTime requestDate;
  final DateTime? approvalDate;
  final DateTime? rejectionDate;
  final DateTime? visitDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Animal? animal;

  Adoption({
    required this.id,
    required this.animalId,
    required this.ownerId,
    required this.adopterId,
    required this.type,
    required this.status,
    required this.requestDate,
    this.approvalDate,
    this.rejectionDate,
    this.visitDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.animal,
  });

  factory Adoption.fromJson(Map<String, dynamic> json) {
    return Adoption(
      id: json['id'] ?? '',
      animalId: json['animalId'] ?? '',
      ownerId: json['ownerId'] ?? '',
      adopterId: json['adopterId'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      requestDate: DateTime.parse(json['requestDate']),
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'])
          : null,
      rejectionDate: json['rejectionDate'] != null
          ? DateTime.parse(json['rejectionDate'])
          : null,
      visitDate: json['visitDate'] != null
          ? DateTime.parse(json['visitDate'])
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      animal: json['animal'] != null
          ? Animal.fromJson(json['animal'])
          : null,
    );
  }
}

class PostAdoptionDashboard {
  final int totalFollowUps;
  final int completedFollowUps;
  final int pendingFollowUps;
  final int atRiskAdoptions;
  final double completionRate;

  PostAdoptionDashboard({
    required this.totalFollowUps,
    required this.completedFollowUps,
    required this.pendingFollowUps,
    required this.atRiskAdoptions,
    required this.completionRate,
  });

  factory PostAdoptionDashboard.fromJson(Map<String, dynamic> json) {
    return PostAdoptionDashboard(
      totalFollowUps: json['totalFollowUps'] ?? 0,
      completedFollowUps: json['completedFollowUps'] ?? 0,
      pendingFollowUps: json['pendingFollowUps'] ?? 0,
      atRiskAdoptions: json['atRiskAdoptions'] ?? 0,
      completionRate: (json['completionRate'] ?? 0).toDouble(),
    );
  }
}

class PostAdoptionAnalytics {
  final String period;
  final double adoptionSuccessRate;
  final double averageAdaptationScore;
  final List<CommonIssue> commonIssues;
  final List<double> satisfactionTrend;

  PostAdoptionAnalytics({
    required this.period,
    required this.adoptionSuccessRate,
    required this.averageAdaptationScore,
    required this.commonIssues,
    required this.satisfactionTrend,
  });

  factory PostAdoptionAnalytics.fromJson(Map<String, dynamic> json) {
    return PostAdoptionAnalytics(
      period: json['period'] ?? '',
      adoptionSuccessRate: (json['adoptionSuccessRate'] ?? 0).toDouble(),
      averageAdaptationScore: (json['averageAdaptationScore'] ?? 0).toDouble(),
      commonIssues: (json['commonIssues'] as List<dynamic>? ?? [])
          .map((item) => CommonIssue.fromJson(item))
          .toList(),
      satisfactionTrend: (json['satisfactionTrend'] as List<double>? ?? [])
          .map((item) => (item ?? 0).toDouble())
          .toList(),
    );
  }
}

class CommonIssue {
  final String issue;
  final int frequency;

  CommonIssue({
    required this.issue,
    required this.frequency,
  });

  factory CommonIssue.fromJson(Map<String, dynamic> json) {
    return CommonIssue(
      issue: json['issue'] ?? '',
      frequency: json['frequency'] ?? 0,
    );
  }
}

class FollowUpFormData {
  final String adaptationLevel;
  final bool eatingWell;
  final bool sleepingWell;
  final bool usingBathroomProperly;
  final bool showingAffection;
  final List<String> behavioralIssues;
  final List<String> healthConcerns;
  final bool vetVisitScheduled;
  final DateTime? vetVisitDate;
  final int satisfactionScore;
  final bool wouldRecommend;
  final String additionalComments;
  final bool needsSupport;
  final List<String> supportType;

  FollowUpFormData({
    required this.adaptationLevel,
    required this.eatingWell,
    required this.sleepingWell,
    required this.usingBathroomProperly,
    required this.showingAffection,
    required this.behavioralIssues,
    required this.healthConcerns,
    required this.vetVisitScheduled,
    this.vetVisitDate,
    required this.satisfactionScore,
    required this.wouldRecommend,
    required this.additionalComments,
    required this.needsSupport,
    required this.supportType,
  });

  Map<String, dynamic> toJson() {
    return {
      'adaptationLevel': adaptationLevel,
      'eatingWell': eatingWell,
      'sleepingWell': sleepingWell,
      'usingBathroomProperly': usingBathroomProperly,
      'showingAffection': showingAffection,
      'behavioralIssues': behavioralIssues,
      'healthConcerns': healthConcerns,
      'vetVisitScheduled': vetVisitScheduled,
      'vetVisitDate': vetVisitDate?.toIso8601String(),
      'satisfactionScore': satisfactionScore,
      'wouldRecommend': wouldRecommend,
      'additionalComments': additionalComments,
      'needsSupport': needsSupport,
      'supportType': supportType,
    };
  }
}