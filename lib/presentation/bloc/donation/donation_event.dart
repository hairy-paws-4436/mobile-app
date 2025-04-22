import 'package:equatable/equatable.dart';

abstract class DonationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchDonationsEvent extends DonationEvent {}

class FetchDonationDetailsEvent extends DonationEvent {
  final String donationId;

  FetchDonationDetailsEvent(this.donationId);

  @override
  List<Object?> get props => [donationId];
}

class CreateDonationEvent extends DonationEvent {
  final Map<String, dynamic> donationData;
  final String? receiptPath;

  CreateDonationEvent({
    required this.donationData,
    this.receiptPath,
  });

  @override
  List<Object?> get props => [donationData, receiptPath];
}

class ConfirmDonationEvent extends DonationEvent {
  final String donationId;
  final String notes;

  ConfirmDonationEvent({
    required this.donationId,
    required this.notes,
  });

  @override
  List<Object?> get props => [donationId, notes];
}

class CancelDonationEvent extends DonationEvent {
  final String donationId;
  final String notes;

  CancelDonationEvent({
    required this.donationId,
    required this.notes,
  });

  @override
  List<Object?> get props => [donationId, notes];
}
