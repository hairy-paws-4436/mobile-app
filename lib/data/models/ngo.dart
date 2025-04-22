class NGO {
  final String id;
  final String name;
  final String ruc;
  final String description;
  final String address;
  final String phone;
  final String email;
  final String? website;
  final String? mission;
  final String? vision;
  final String bankAccount;
  final String bankName;
  final String interbankAccount;
  final String? logo;
  final String ownerId;

  NGO({
    required this.id,
    required this.name,
    required this.ruc,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    this.website,
    this.mission,
    this.vision,
    required this.bankAccount,
    required this.bankName,
    required this.interbankAccount,
    this.logo,
    required this.ownerId,
  });

  factory NGO.fromJson(Map<String, dynamic> json) {
    return NGO(
      id: json['id'],
      name: json['name'],
      ruc: json['ruc'],
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      mission: json['mission'],
      vision: json['vision'],
      bankAccount: json['bankAccount'],
      bankName: json['bankName'],
      interbankAccount: json['interbankAccount'],
      logo: json['logo'],
      ownerId: json['ownerId'],
    );
  }
}
