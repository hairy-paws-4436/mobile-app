import '../models/donation.dart';
import '../services/donation_service.dart';

class DonationRepository {
  final DonationService donationService;

  DonationRepository({required this.donationService});

  Future<void> createDonation(Map<String, dynamic> donationData, String? receiptPath) async {
    try {
      await donationService.createDonation(donationData, receiptPath);
    } catch (e) {
      throw e;
    }
  }

  Future<List<Donation>> getDonations() async {
    try {
      return await donationService.getDonations();
    } catch (e) {
      throw e;
    }
  }

  Future<Donation> getDonationDetails(String id) async {
    try {
      return await donationService.getDonationDetails(id);
    } catch (e) {
      throw e;
    }
  }

  Future<void> confirmDonation(String id, String notes) async {
    try {
      await donationService.confirmDonation(id, notes);
    } catch (e) {
      throw e;
    }
  }

  Future<void> cancelDonation(String id, String notes) async {
    try {
      await donationService.cancelDonation(id, notes);
    } catch (e) {
      throw e;
    }
  }
}
