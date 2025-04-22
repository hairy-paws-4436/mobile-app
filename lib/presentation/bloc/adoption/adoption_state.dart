import 'package:equatable/equatable.dart';
import '../../../data/models/adoption_request.dart';

abstract class AdoptionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdoptionInitial extends AdoptionState {}

class AdoptionLoading extends AdoptionState {}

class AdoptionRequestsLoaded extends AdoptionState {
  final List<AdoptionRequest> requests;

  AdoptionRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class AdoptionDetailsLoaded extends AdoptionState {
  final AdoptionRequest request;

  AdoptionDetailsLoaded(this.request);

  @override
  List<Object?> get props => [request];
}

class AdoptionRequestCreated extends AdoptionState {}

class AdoptionRequestApproved extends AdoptionState {}

class AdoptionRequestRejected extends AdoptionState {}

class AdoptionRequestCancelled extends AdoptionState {}

class AdoptionError extends AdoptionState {
  final String message;

  AdoptionError(this.message);

  @override
  List<Object?> get props => [message];
}
