import 'package:equatable/equatable.dart';
import '../../../data/models/donation.dart';

abstract class DonationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DonationInitial extends DonationState {}

class DonationLoading extends DonationState {}

class DonationsLoaded extends DonationState {
  final List<Donation> donations;

  DonationsLoaded(this.donations);

  @override
  List<Object?> get props => [donations];
}

class DonationDetailsLoaded extends DonationState {
  final Donation donation;

  DonationDetailsLoaded(this.donation);

  @override
  List<Object?> get props => [donation];
}

class DonationCreated extends DonationState {}

class DonationConfirmed extends DonationState {}

class DonationCancelled extends DonationState {}

class DonationError extends DonationState {
  final String message;

  DonationError(this.message);

  @override
  List<Object?> get props => [message];
}
