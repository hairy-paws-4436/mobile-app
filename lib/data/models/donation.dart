class DonationItem {
  final String name;
  final int quantity;
  final String description;

  DonationItem({
    required this.name,
    required this.quantity,
    required this.description,
  });

  factory DonationItem.fromJson(Map<String, dynamic> json) {
    return DonationItem(
      name: json['name'],
      quantity: json['quantity'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'description': description,
    };
  }
}

class Donation {
  final String id;
  final String ongId;
  final String donorId;
  final String type;
  final double? amount;
  final String? transactionId;
  final List<DonationItem>? items;
  final String? notes;
  final String? receipt;
  final String status;

  Donation({
    required this.id,
    required this.ongId,
    required this.donorId,
    required this.type,
    this.amount,
    this.transactionId,
    this.items,
    this.notes,
    this.receipt,
    required this.status,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    List<DonationItem>? items;
    if (json['items'] != null) {
      items = (json['items'] as List).map((item) => DonationItem.fromJson(item)).toList();
    }

    return Donation(
      id: json['id'],
      ongId: json['ongId'],
      donorId: json['donorId'],
      type: json['type'],
      amount: json['amount'],
      transactionId: json['transactionId'],
      items: items,
      notes: json['notes'],
      receipt: json['receipt'],
      status: json['status'],
    );
  }
}
