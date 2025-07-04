class NotificationTemplate {
  final String name;
  final String description;
  final Map<String, dynamic> config;

  NotificationTemplate({
    required this.name,
    required this.description,
    required this.config,
  });

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) {
    return NotificationTemplate(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      config: Map<String, dynamic>.from(json['config'] ?? {}),
    );
  }
}

class NotificationTemplates {
  final NotificationTemplate minimal;
  final NotificationTemplate balanced;
  final NotificationTemplate everything;

  NotificationTemplates({
    required this.minimal,
    required this.balanced,
    required this.everything,
  });

  factory NotificationTemplates.fromJson(Map<String, dynamic> json) {
    return NotificationTemplates(
      minimal: NotificationTemplate.fromJson(json['minimal']),
      balanced: NotificationTemplate.fromJson(json['balanced']),
      everything: NotificationTemplate.fromJson(json['everything']),
    );
  }

  List<NotificationTemplate> get allTemplates => [minimal, balanced, everything];

  List<String> get templateKeys => ['minimal', 'balanced', 'everything'];
}

// Enums para coincidir exactamente con el backend
enum NotificationFrequency {
  immediate('immediate', 'Inmediato'),
  daily_digest('daily_digest', 'Resumen diario'),
  weekly_digest('weekly_digest', 'Resumen semanal'),
  disabled('disabled', 'Deshabilitado');

  const NotificationFrequency(this.value, this.label);
  final String value;
  final String label;
}

enum NotificationChannel {
  in_app('in_app', 'En la app'),
  email('email', 'Email'),
  sms('sms', 'SMS'),
  push('push', 'Push');

  const NotificationChannel(this.value, this.label);
  final String value;
  final String label;
}

enum AnimalType {
  dog('dog', 'Perro'),
  cat('cat', 'Gato'),
  rabbit('rabbit', 'Conejo'),
  bird('bird', 'Ave'),
  other('other', 'Otro');

  const AnimalType(this.value, this.label);
  final String value;
  final String label;
}