import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/donation_repository.dart';
import 'donation_event.dart';
import 'donation_state.dart';

class DonationBloc extends Bloc<DonationEvent, DonationState> {
  final DonationRepository donationRepository;

  DonationBloc({required this.donationRepository}) : super(DonationInitial()) {
    on<FetchDonationsEvent>(_onFetchDonations);
    on<FetchDonationDetailsEvent>(_onFetchDonationDetails);
    on<CreateDonationEvent>(_onCreateDonation);
    on<ConfirmDonationEvent>(_onConfirmDonation);
    on<CancelDonationEvent>(_onCancelDonation);
  }

  Future<void> _onFetchDonations(
      FetchDonationsEvent event,
      Emitter<DonationState> emit,
      ) async {
    emit(DonationLoading());
    try {
      final donations = await donationRepository.getDonations();
      emit(DonationsLoaded(donations));
    } catch (e) {
      emit(DonationError(e.toString()));
    }
  }

  Future<void> _onFetchDonationDetails(
      FetchDonationDetailsEvent event,
      Emitter<DonationState> emit,
      ) async {
    emit(DonationLoading());
    try {
      final donation = await donationRepository.getDonationDetails(event.donationId);
      emit(DonationDetailsLoaded(donation));
    } catch (e) {
      emit(DonationError(e.toString()));
    }
  }

  Future<void> _onCreateDonation(
      CreateDonationEvent event,
      Emitter<DonationState> emit,
      ) async {
    emit(DonationLoading());
    try {
      await donationRepository.createDonation(
        event.donationData,
        event.receiptPath,
      );
      emit(DonationCreated());
    } catch (e) {
      emit(DonationError(e.toString()));
    }
  }

  Future<void> _onConfirmDonation(
      ConfirmDonationEvent event,
      Emitter<DonationState> emit,
      ) async {
    emit(DonationLoading());
    try {
      await donationRepository.confirmDonation(event.donationId, event.notes);
      emit(DonationConfirmed());
    } catch (e) {
      emit(DonationError(e.toString()));
    }
  }

  Future<void> _onCancelDonation(
      CancelDonationEvent event,
      Emitter<DonationState> emit,
      ) async {
    emit(DonationLoading());
    try {
      await donationRepository.cancelDonation(event.donationId, event.notes);
      emit(DonationCancelled());
    } catch (e) {
      emit(DonationError(e.toString()));
    }
  }
}
