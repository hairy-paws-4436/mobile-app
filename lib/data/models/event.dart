class Event {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final DateTime? endDate;
  final String location;
  final bool isVolunteerEvent;
  final int? maxParticipants;
  final String? requirements;
  final String? image;
  final String organizerId;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    this.endDate,
    required this.location,
    required this.isVolunteerEvent,
    this.maxParticipants,
    this.requirements,
    this.image,
    required this.organizerId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      eventDate: DateTime.parse(json['eventDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      location: json['location'] ?? '',
      isVolunteerEvent: json['isVolunteerEvent'] ?? true,
      maxParticipants: json['maxParticipants'] ?? 0,
      requirements: json['requirements'] ?? '',
      image: json['image'] ?? '',
      organizerId: json['organizerId'] ?? '',
    );
  }
}
