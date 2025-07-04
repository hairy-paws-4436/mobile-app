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
  final bool sterilized;
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
    required this.sterilized,
    required this.images,
    required this.ownerId,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    // Filtrar imágenes vacías o inválidas
    List<String> validImages = [];
    if (json['images'] != null) {
      for (var image in json['images']) {
        String? imageUrl;

        if (image is String) {
          imageUrl = image;
        } else if (image is Map && image['imageUrl'] != null) {
          imageUrl = image['imageUrl'].toString();
        }

        // Solo agregar URLs válidas que no estén vacías y sean URLs reales
        if (imageUrl != null &&
            imageUrl.trim().isNotEmpty &&
            (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
          validImages.add(imageUrl);
        }
      }
    }

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
      vaccinated: json['vaccinated'] ?? false,
      sterilized: json['sterilized'] ?? false,
      images: validImages,
      ownerId: json['ownerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'age': age,
      'gender': gender,
      'description': description,
      'weight': weight,
      'healthDetails': healthDetails,
      'vaccinated': vaccinated,
      'sterilized': sterilized,
      'images': images,
      'ownerId': ownerId,
    };
  }

  // Helper method para obtener la primera imagen válida
  String? get firstValidImage {
    if (images.isEmpty) return null;
    return images.first;
  }

  // Helper method para verificar si tiene imágenes válidas
  bool get hasValidImages => images.isNotEmpty;
}