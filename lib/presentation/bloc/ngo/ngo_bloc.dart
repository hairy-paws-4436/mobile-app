import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/ngo_repository.dart';
import 'ngo_event.dart';
import 'ngo_state.dart';

class NGOBloc extends Bloc<NGOEvent, NGOState> {
  final NGORepository ngoRepository;

  NGOBloc({required this.ngoRepository}) : super(NGOInitial()) {
    on<FetchNGOsEvent>(_onFetchNGOs);
    on<FetchNGODetailsEvent>(_onFetchNGODetails);
    on<FetchUserNGOEvent>(_onFetchUserNGO);
    on<RegisterNGOEvent>(_onRegisterNGO);
    on<UpdateNGOEvent>(_onUpdateNGO);
  }

  Future<void> _onFetchNGOs(
      FetchNGOsEvent event,
      Emitter<NGOState> emit,
      ) async {
    emit(NGOLoading());
    try {
      final ngos = await ngoRepository.getNGOs();
      emit(NGOsLoaded(ngos));
    } catch (e) {
      emit(NGOError(e.toString()));
    }
  }

  Future<void> _onFetchNGODetails(
      FetchNGODetailsEvent event,
      Emitter<NGOState> emit,
      ) async {
    emit(NGOLoading());
    try {
      final ngo = await ngoRepository.getNGODetails(event.ngoId);
      emit(NGODetailsLoaded(ngo));
    } catch (e) {
      emit(NGOError(e.toString()));
    }
  }

  Future<void> _onFetchUserNGO(
      FetchUserNGOEvent event,
      Emitter<NGOState> emit,
      ) async {
    emit(NGOLoading());
    try {
      final ngo = await ngoRepository.getUserNGO();
      emit(UserNGOLoaded(ngo));
    } catch (e) {
      emit(NGOError(e.toString()));
    }
  }

  Future<void> _onRegisterNGO(
      RegisterNGOEvent event,
      Emitter<NGOState> emit,
      ) async {
    emit(NGOLoading());
    try {
      final ngo = await ngoRepository.registerNGO(
        event.ngoData,
        event.logoPath,
      );
      emit(NGORegistered(ngo));
    } catch (e) {
      emit(NGOError(e.toString()));
    }
  }

  Future<void> _onUpdateNGO(
      UpdateNGOEvent event,
      Emitter<NGOState> emit,
      ) async {
    emit(NGOLoading());
    try {
      final ngo = await ngoRepository.updateNGO(
        event.ngoId,
        event.ngoData,
      );
      emit(NGOUpdated(ngo));
    } catch (e) {
      emit(NGOError(e.toString()));
    }
  }
}
