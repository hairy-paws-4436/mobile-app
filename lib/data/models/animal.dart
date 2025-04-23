class Animal {
  final String id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String gender;
  final String size;
  final String color;
  final String description;
  final List<String> images;
  final bool isAdopted;
  final String ownerId;
  final String? medicalInfo;
  final String? vaccinationStatus;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.gender,
    required this.size,
    required this.color,
    required this.description,
    required this.images,
    required this.isAdopted,
    required this.ownerId,
    this.medicalInfo,
    this.vaccinationStatus,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      breed: json['breed'] ?? '',
      age: json['age'] ?? '',
      gender: json['gender'] ?? '',
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images']) ,
      isAdopted: json['isAdopted'] ?? false,
      ownerId: json['ownerId'] ?? '',
      medicalInfo: json['medicalInfo'] ?? '',
      vaccinationStatus: json['vaccinationStatus'] ?? '',
    );
  }
}
