class AppNotification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? referenceId;
  final String? relatedEntityId; // Generic ID for any entity
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.referenceId,
    this.relatedEntityId,
    this.metadata,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      referenceId: json['referenceId'],
      relatedEntityId: json['relatedEntityId'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Helper methods
  bool get isDonationNotification => type.toLowerCase() == 'donation_received';
  bool get isAdoptionRequest => type.toLowerCase() == 'adoption_request';
  bool get isVisitRequest => type.toLowerCase() == 'visit_request';

  // Extract IDs from message if not provided in specific fields
  String? get extractedDonationId {
    if (referenceId != null) return referenceId;
    final regex = RegExp(r'donation[:\s]+([a-zA-Z0-9-]+)', caseSensitive: false);
    final match = regex.firstMatch(message);
    return match?.group(1);
  }

  String? get extractedAdoptionId {
    if (referenceId != null) return referenceId;
    final regex = RegExp(r'adoption[:\s]+([a-zA-Z0-9-]+)', caseSensitive: false);
    final match = regex.firstMatch(message);
    return match?.group(1);
  }

  String? get extractedVisitId {
    if (referenceId != null) return referenceId;
    final regex = RegExp(r'visit[:\s]+([a-zA-Z0-9-]+)', caseSensitive: false);
    final match = regex.firstMatch(message);
    return match?.group(1);
  }
}