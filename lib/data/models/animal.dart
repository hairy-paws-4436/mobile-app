class Animal {
  final String id;
  final String name;
  final String type;
  final String breed;
  final int age;
  final String gender;
  final String description;
  final double weight;
  final String healthDetails;
  final bool vaccinated;
  final bool sterilized ;
  final List<String> images;
  final String? ownerId;

  Animal({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    required this.gender,
    required this.description,
    required this.weight,
    required this.healthDetails,
    required this.vaccinated,
    required this.sterilized ,
    required this.images,
    required this.ownerId,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      breed: json['breed'] ?? '',
      age: json['age'] is int ? json['age'] : int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      gender: json['gender'] ?? '',
      description: json['description'] ?? '',
      weight: json['weight'] is double
          ? json['weight']
          : double.tryParse(json['weight']?.toString() ?? '0.0') ?? 0.0,
      healthDetails: json['healthDetails'] ?? '',
      vaccinated : json['vaccinated'] ?? false,
      sterilized : json['sterilized'] ?? false,
      images: List<String>.from(json['images']) ,
      ownerId: json['ownerId'] ?? '',
    );
  }
}
