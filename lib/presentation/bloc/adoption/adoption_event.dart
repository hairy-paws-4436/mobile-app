import 'package:equatable/equatable.dart';
import '../../../data/models/adoption_request.dart';


abstract class AdoptionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAdoptionRequestsEvent extends AdoptionEvent {}

class FetchAdoptionDetailsEvent extends AdoptionEvent {
  final String requestId;

  FetchAdoptionDetailsEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class CreateAdoptionRequestEvent extends AdoptionEvent {
  final AdoptionRequest request;

  CreateAdoptionRequestEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class ApproveAdoptionRequestEvent extends AdoptionEvent {
  final String requestId;
  final String notes;

  ApproveAdoptionRequestEvent({
    required this.requestId,
    required this.notes,
  });

  @override
  List<Object?> get props => [requestId, notes];
}

class RejectAdoptionRequestEvent extends AdoptionEvent {
  final String requestId;
  final String notes;

  RejectAdoptionRequestEvent({
    required this.requestId,
    required this.notes,
  });

  @override
  List<Object?> get props => [requestId, notes];
}

class CancelAdoptionRequestEvent extends AdoptionEvent {
  final String requestId;
  final String notes;

  CancelAdoptionRequestEvent({
    required this.requestId,
    required this.notes,
  });

  @override
  List<Object?> get props => [requestId, notes];
}
