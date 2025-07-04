
class NotificationPreferences {
  final String id;
  final String userId;
  final bool globalNotificationsEnabled;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final List<String> preferredChannels;

  // Adoption notifications
  final bool adoptionRequestsEnabled;
  final String adoptionRequestsFrequency;
  final bool adoptionStatusEnabled;
  final String adoptionStatusFrequency;

  // Matching notifications
  final bool newMatchesEnabled;
  final String newMatchesFrequency;
  final bool newAnimalsEnabled;
  final String newAnimalsFrequency;

  // Donation notifications
  final bool donationConfirmationsEnabled;
  final String donationConfirmationsFrequency;

  // Event notifications
  final bool eventRemindersEnabled;
  final String eventRemindersFrequency;
  final bool newEventsEnabled;
  final String newEventsFrequency;

  // Other notifications
  final bool followupRemindersEnabled;
  final String followupRemindersFrequency;
  final bool accountUpdatesEnabled;
  final String accountUpdatesFrequency;

  // Filtering preferences
  final List<String>? preferredAnimalTypesForNotifications;
  final int maxDistanceNotificationsKm;
  final bool onlyHighCompatibility;

  // Marketing preferences
  final bool promotionalEnabled;
  final bool newsletterEnabled;

  // Settings
  final DateTime? lastDigestSent;
  final String timezone;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationPreferences({
    required this.id,
    required this.userId,
    required this.globalNotificationsEnabled,
    required this.quietHoursEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.preferredChannels,
    required this.adoptionRequestsEnabled,
    required this.adoptionRequestsFrequency,
    required this.adoptionStatusEnabled,
    required this.adoptionStatusFrequency,
    required this.newMatchesEnabled,
    required this.newMatchesFrequency,
    required this.newAnimalsEnabled,
    required this.newAnimalsFrequency,
    required this.donationConfirmationsEnabled,
    required this.donationConfirmationsFrequency,
    required this.eventRemindersEnabled,
    required this.eventRemindersFrequency,
    required this.newEventsEnabled,
    required this.newEventsFrequency,
    required this.followupRemindersEnabled,
    required this.followupRemindersFrequency,
    required this.accountUpdatesEnabled,
    required this.accountUpdatesFrequency,
    this.preferredAnimalTypesForNotifications,
    required this.maxDistanceNotificationsKm,
    required this.onlyHighCompatibility,
    required this.promotionalEnabled,
    required this.newsletterEnabled,
    this.lastDigestSent,
    required this.timezone,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      globalNotificationsEnabled: json['globalNotificationsEnabled'] ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] ?? false,
      // Asegurar formato correcto HH:MM (sin segundos)
      quietHoursStart: json['quietHoursStart']?.toString().substring(0, 5) ?? '22:00',
      quietHoursEnd: json['quietHoursEnd']?.toString().substring(0, 5) ?? '07:00',
      preferredChannels: List<String>.from(json['preferredChannels'] ?? ['in_app']),
      adoptionRequestsEnabled: json['adoptionRequestsEnabled'] ?? true,
      adoptionRequestsFrequency: json['adoptionRequestsFrequency'] ?? 'immediate',
      adoptionStatusEnabled: json['adoptionStatusEnabled'] ?? true,
      adoptionStatusFrequency: json['adoptionStatusFrequency'] ?? 'immediate',
      newMatchesEnabled: json['newMatchesEnabled'] ?? true,
      newMatchesFrequency: json['newMatchesFrequency'] ?? 'daily_digest',
      newAnimalsEnabled: json['newAnimalsEnabled'] ?? true,
      newAnimalsFrequency: json['newAnimalsFrequency'] ?? 'weekly_digest',
      donationConfirmationsEnabled: json['donationConfirmationsEnabled'] ?? true,
      donationConfirmationsFrequency: json['donationConfirmationsFrequency'] ?? 'immediate',
      eventRemindersEnabled: json['eventRemindersEnabled'] ?? true,
      eventRemindersFrequency: json['eventRemindersFrequency'] ?? 'immediate',
      newEventsEnabled: json['newEventsEnabled'] ?? false,
      newEventsFrequency: json['newEventsFrequency'] ?? 'weekly_digest',
      followupRemindersEnabled: json['followupRemindersEnabled'] ?? true,
      followupRemindersFrequency: json['followupRemindersFrequency'] ?? 'immediate',
      accountUpdatesEnabled: json['accountUpdatesEnabled'] ?? true,
      accountUpdatesFrequency: json['accountUpdatesFrequency'] ?? 'immediate',
      preferredAnimalTypesForNotifications: json['preferredAnimalTypesForNotifications'] != null
          ? List<String>.from(json['preferredAnimalTypesForNotifications'])
          : null,
      maxDistanceNotificationsKm: json['maxDistanceNotificationsKm'] is String
          ? int.parse(json['maxDistanceNotificationsKm'])
          : json['maxDistanceNotificationsKm'] ?? 50,
      onlyHighCompatibility: json['onlyHighCompatibility'] ?? false,
      promotionalEnabled: json['promotionalEnabled'] ?? false,
      newsletterEnabled: json['newsletterEnabled'] ?? true,
      lastDigestSent: json['lastDigestSent'] != null
          ? DateTime.parse(json['lastDigestSent'])
          : null,
      timezone: json['timezone'] ?? 'America/Lima',
      language: json['language'] ?? 'es',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    // Enviar TODOS los campos sin lógica condicional
    final Map<String, dynamic> json = {};

    // Campos básicos
    json['globalNotificationsEnabled'] = globalNotificationsEnabled;
    json['quietHoursEnabled'] = quietHoursEnabled;

    // Enviar horas siempre, pero asegurar formato HH:MM
    json['quietHoursStart'] = quietHoursStart.length > 5 ? quietHoursStart.substring(0, 5) : quietHoursStart;
    json['quietHoursEnd'] = quietHoursEnd.length > 5 ? quietHoursEnd.substring(0, 5) : quietHoursEnd;

    json['preferredChannels'] = preferredChannels;

    // Adopciones - SIEMPRE enviar ambos campos
    json['adoptionRequestsEnabled'] = adoptionRequestsEnabled;
    json['adoptionRequestsFrequency'] = adoptionRequestsFrequency;
    json['adoptionStatusEnabled'] = adoptionStatusEnabled;
    json['adoptionStatusFrequency'] = adoptionStatusFrequency;

    // Matching - SIEMPRE enviar ambos campos
    json['newMatchesEnabled'] = newMatchesEnabled;
    json['newMatchesFrequency'] = newMatchesFrequency;
    json['newAnimalsEnabled'] = newAnimalsEnabled;
    json['newAnimalsFrequency'] = newAnimalsFrequency;

    // Donaciones - SIEMPRE enviar ambos campos
    json['donationConfirmationsEnabled'] = donationConfirmationsEnabled;
    json['donationConfirmationsFrequency'] = donationConfirmationsFrequency;

    // Eventos - SIEMPRE enviar ambos campos
    json['eventRemindersEnabled'] = eventRemindersEnabled;
    json['eventRemindersFrequency'] = eventRemindersFrequency;
    json['newEventsEnabled'] = newEventsEnabled;
    json['newEventsFrequency'] = newEventsFrequency;

    // Seguimiento - SIEMPRE enviar ambos campos
    json['followupRemindersEnabled'] = followupRemindersEnabled;
    json['followupRemindersFrequency'] = followupRemindersFrequency;

    // Cuenta - SIEMPRE enviar ambos campos
    json['accountUpdatesEnabled'] = accountUpdatesEnabled;
    json['accountUpdatesFrequency'] = accountUpdatesFrequency;

    // Filtros avanzados
    if (preferredAnimalTypesForNotifications != null && preferredAnimalTypesForNotifications!.isNotEmpty) {
      json['preferredAnimalTypesForNotifications'] = preferredAnimalTypesForNotifications;
    }
    json['maxDistanceNotificationsKm'] = maxDistanceNotificationsKm;
    json['onlyHighCompatibility'] = onlyHighCompatibility;

    // Marketing
    json['promotionalEnabled'] = promotionalEnabled;
    json['newsletterEnabled'] = newsletterEnabled;

    // Configuración
    json['timezone'] = timezone;
    json['language'] = language;

    return json;
  }

  NotificationPreferences copyWith({
    String? id,
    String? userId,
    bool? globalNotificationsEnabled,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    List<String>? preferredChannels,
    bool? adoptionRequestsEnabled,
    String? adoptionRequestsFrequency,
    bool? adoptionStatusEnabled,
    String? adoptionStatusFrequency,
    bool? newMatchesEnabled,
    String? newMatchesFrequency,
    bool? newAnimalsEnabled,
    String? newAnimalsFrequency,
    bool? donationConfirmationsEnabled,
    String? donationConfirmationsFrequency,
    bool? eventRemindersEnabled,
    String? eventRemindersFrequency,
    bool? newEventsEnabled,
    String? newEventsFrequency,
    bool? followupRemindersEnabled,
    String? followupRemindersFrequency,
    bool? accountUpdatesEnabled,
    String? accountUpdatesFrequency,
    List<String>? preferredAnimalTypesForNotifications,
    int? maxDistanceNotificationsKm,
    bool? onlyHighCompatibility,
    bool? promotionalEnabled,
    bool? newsletterEnabled,
    DateTime? lastDigestSent,
    String? timezone,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      globalNotificationsEnabled: globalNotificationsEnabled ?? this.globalNotificationsEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      preferredChannels: preferredChannels ?? this.preferredChannels,
      adoptionRequestsEnabled: adoptionRequestsEnabled ?? this.adoptionRequestsEnabled,
      adoptionRequestsFrequency: adoptionRequestsFrequency ?? this.adoptionRequestsFrequency,
      adoptionStatusEnabled: adoptionStatusEnabled ?? this.adoptionStatusEnabled,
      adoptionStatusFrequency: adoptionStatusFrequency ?? this.adoptionStatusFrequency,
      newMatchesEnabled: newMatchesEnabled ?? this.newMatchesEnabled,
      newMatchesFrequency: newMatchesFrequency ?? this.newMatchesFrequency,
      newAnimalsEnabled: newAnimalsEnabled ?? this.newAnimalsEnabled,
      newAnimalsFrequency: newAnimalsFrequency ?? this.newAnimalsFrequency,
      donationConfirmationsEnabled: donationConfirmationsEnabled ?? this.donationConfirmationsEnabled,
      donationConfirmationsFrequency: donationConfirmationsFrequency ?? this.donationConfirmationsFrequency,
      eventRemindersEnabled: eventRemindersEnabled ?? this.eventRemindersEnabled,
      eventRemindersFrequency: eventRemindersFrequency ?? this.eventRemindersFrequency,
      newEventsEnabled: newEventsEnabled ?? this.newEventsEnabled,
      newEventsFrequency: newEventsFrequency ?? this.newEventsFrequency,
      followupRemindersEnabled: followupRemindersEnabled ?? this.followupRemindersEnabled,
      followupRemindersFrequency: followupRemindersFrequency ?? this.followupRemindersFrequency,
      accountUpdatesEnabled: accountUpdatesEnabled ?? this.accountUpdatesEnabled,
      accountUpdatesFrequency: accountUpdatesFrequency ?? this.accountUpdatesFrequency,
      preferredAnimalTypesForNotifications: preferredAnimalTypesForNotifications ?? this.preferredAnimalTypesForNotifications,
      maxDistanceNotificationsKm: maxDistanceNotificationsKm ?? this.maxDistanceNotificationsKm,
      onlyHighCompatibility: onlyHighCompatibility ?? this.onlyHighCompatibility,
      promotionalEnabled: promotionalEnabled ?? this.promotionalEnabled,
      newsletterEnabled: newsletterEnabled ?? this.newsletterEnabled,
      lastDigestSent: lastDigestSent ?? this.lastDigestSent,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}