import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/animal_repository.dart';
import 'animal_event.dart';
import 'animal_state.dart';

class AnimalBloc extends Bloc<AnimalEvent, AnimalState> {
  final AnimalRepository animalRepository;

  AnimalBloc({required this.animalRepository}) : super(AnimalInitial()) {
    on<FetchAnimalsEvent>(_onFetchAnimals);
    on<FetchAnimalDetailsEvent>(_onFetchAnimalDetails);
    on<FetchOwnerAnimalsEvent>(_onFetchOwnerAnimals);
    on<CreateAnimalEvent>(_onCreateAnimal);
    on<UpdateAnimalEvent>(_onUpdateAnimal);
    on<DeleteAnimalEvent>(_onDeleteAnimal);
  }

  Future<void> _onFetchAnimals(
    FetchAnimalsEvent event,
    Emitter<AnimalState> emit,
  ) async {
    if (state is! AnimalsLoaded) {
      emit(AnimalLoading());
    }

    try {
      final animals = await animalRepository.getAnimals();
      emit(AnimalsLoaded(animals));
    } catch (e) {
      emit(AnimalError(e.toString()));
    }
  }

  Future<void> _onFetchAnimalDetails(
    FetchAnimalDetailsEvent event,
    Emitter<AnimalState> emit,
  ) async {
    emit(AnimalLoading());
    try {
      final animal = await animalRepository.getAnimalDetails(event.animalId);
      emit(AnimalDetailsLoaded(animal));
    } catch (e) {
      emit(AnimalError(e.toString()));
    }
  }

  Future<void> _onFetchOwnerAnimals(
    FetchOwnerAnimalsEvent event,
    Emitter<AnimalState> emit,
  ) async {
    emit(AnimalLoading());
    try {
      final animals = await animalRepository.getOwnerAnimals();
      emit(OwnerAnimalsLoaded(animals));
    } catch (e) {
      emit(AnimalError(e.toString()));
    }
  }

  Future<void> _onCreateAnimal(
    CreateAnimalEvent event,
    Emitter<AnimalState> emit,
  ) async {
    emit(AnimalLoading());
    try {
      final animal = await animalRepository.createAnimal(
        event.animalData,
        event.imagePaths,
      );
      emit(AnimalCreated(animal));
    } catch (e) {
      emit(AnimalError(e.toString()));
    }
  }

  Future<void> _onUpdateAnimal(
    UpdateAnimalEvent event,
    Emitter<AnimalState> emit,
  ) async {
    emit(AnimalLoading());
    try {
      final animal = await animalRepository.updateAnimal(
        event.animalId,
        event.animalData,
      );
      emit(AnimalUpdated(animal));
    } catch (e) {
      emit(AnimalError(e.toString()));
    }
  }

  Future<void> _onDeleteAnimal(
    DeleteAnimalEvent event,
    Emitter<AnimalState> emit,
  ) async {
    emit(AnimalLoading());
    try {
      await animalRepository.deleteAnimal(event.animalId);
      emit(AnimalDeleted());
    } catch (e) {
      emit(AnimalError(e.toString()));
    }
  }
}
