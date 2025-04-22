import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/adoption_repository.dart';
import 'adoption_event.dart';
import 'adoption_state.dart';


class AdoptionBloc extends Bloc<AdoptionEvent, AdoptionState> {
  final AdoptionRepository adoptionRepository;

  AdoptionBloc({required this.adoptionRepository}) : super(AdoptionInitial()) {
    on<FetchAdoptionRequestsEvent>(_onFetchAdoptionRequests);
    on<FetchAdoptionDetailsEvent>(_onFetchAdoptionDetails);
    on<CreateAdoptionRequestEvent>(_onCreateAdoptionRequest);
    on<ApproveAdoptionRequestEvent>(_onApproveAdoptionRequest);
    on<RejectAdoptionRequestEvent>(_onRejectAdoptionRequest);
    on<CancelAdoptionRequestEvent>(_onCancelAdoptionRequest);
  }

  Future<void> _onFetchAdoptionRequests(
      FetchAdoptionRequestsEvent event,
      Emitter<AdoptionState> emit,
      ) async {
    emit(AdoptionLoading());
    try {
      final requests = await adoptionRepository.getAdoptionRequests();
      emit(AdoptionRequestsLoaded(requests));
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }

  Future<void> _onFetchAdoptionDetails(
      FetchAdoptionDetailsEvent event,
      Emitter<AdoptionState> emit,
      ) async {
    emit(AdoptionLoading());
    try {
      final request = await adoptionRepository.getAdoptionRequestDetails(event.requestId);
      emit(AdoptionDetailsLoaded(request));
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }

  Future<void> _onCreateAdoptionRequest(
      CreateAdoptionRequestEvent event,
      Emitter<AdoptionState> emit,
      ) async {
    emit(AdoptionLoading());
    try {
      await adoptionRepository.requestAdoption(event.request);
      emit(AdoptionRequestCreated());
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }

  Future<void> _onApproveAdoptionRequest(
      ApproveAdoptionRequestEvent event,
      Emitter<AdoptionState> emit,
      ) async {
    emit(AdoptionLoading());
    try {
      await adoptionRepository.approveAdoptionRequest(event.requestId, event.notes);
      emit(AdoptionRequestApproved());
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }

  Future<void> _onRejectAdoptionRequest(
      RejectAdoptionRequestEvent event,
      Emitter<AdoptionState> emit,
      ) async {
    emit(AdoptionLoading());
    try {
      await adoptionRepository.rejectAdoptionRequest(event.requestId, event.notes);
      emit(AdoptionRequestRejected());
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }

  Future<void> _onCancelAdoptionRequest(
      CancelAdoptionRequestEvent event,
      Emitter<AdoptionState> emit,
      ) async {
    emit(AdoptionLoading());
    try {
      await adoptionRepository.cancelAdoptionRequest(event.requestId, event.notes);
      emit(AdoptionRequestCancelled());
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }
}
