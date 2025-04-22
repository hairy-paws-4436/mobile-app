import 'dart:convert';
import '../models/donation.dart';
import 'api_client.dart';

class DonationService {
  final ApiClient apiClient;

  DonationService({required this.apiClient});

  Future<void> createDonation(Map<String, dynamic> donationData, String? receiptPath) async {
    final fields = donationData.map((key, value) {
      if (value is List) {
        return MapEntry(key, json.encode(value));
      }
      return MapEntry(key, value.toString());
    });

    final files = <String, String>{};
    if (receiptPath != null) {
      files['receipt'] = receiptPath;
    }

    await apiClient.multipartPost('/api/donations', fields: fields, files: files);
  }

  Future<List<Donation>> getDonations() async {
    final response = await apiClient.get('/api/donations');
    return (response as List).map((json) => Donation.fromJson(json)).toList();
  }

  Future<Donation> getDonationDetails(String id) async {
    final response = await apiClient.get('/api/donations/$id');
    return Donation.fromJson(response);
  }

  Future<void> confirmDonation(String id, String notes) async {
    await apiClient.put('/api/donations/$id/confirm', body: {'notes': notes});
  }

  Future<void> cancelDonation(String id, String notes) async {
    await apiClient.put('/api/donations/$id/cancel', body: {'notes': notes});
  }
}
