class AdoptionRequest {
  final String id;
  final String animalId;
  final String type;
  final DateTime? visitDate;
  final String notes;
  final String status;
  final String requesterId;

  AdoptionRequest({
    required this.id,
    required this.animalId,
    required this.type,
    this.visitDate,
    required this.notes,
    required this.status,
    required this.requesterId,
  });

  factory AdoptionRequest.fromJson(Map<String, dynamic> json) {
    return AdoptionRequest(
      id: json['id'] ?? '',
      animalId: json['animalId'] ?? '',
      type: json['type'] ?? '',
      visitDate: DateTime.parse(json['visitDate']),
      notes: json['notes'] ?? '',
      status: json['status'] ?? '',
      requesterId: json['requesterId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animalId': animalId,
      'type': type,
      'visitDate': visitDate?.toIso8601String(),
      'notes': notes,
    };
  }
}
