import 'package:equatable/equatable.dart';

abstract class AnimalEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAnimalsEvent extends AnimalEvent {}

class FetchAnimalDetailsEvent extends AnimalEvent {
  final String animalId;

  FetchAnimalDetailsEvent(this.animalId);

  @override
  List<Object?> get props => [animalId];
}

class FetchOwnerAnimalsEvent extends AnimalEvent {}

class CreateAnimalEvent extends AnimalEvent {
  final Map<String, dynamic> animalData;
  final List<String> imagePaths;

  CreateAnimalEvent({
    required this.animalData,
    required this.imagePaths,
  });

  @override
  List<Object?> get props => [animalData, imagePaths];
}

class UpdateAnimalEvent extends AnimalEvent {
  final String animalId;
  final Map<String, dynamic> animalData;

  UpdateAnimalEvent({
    required this.animalId,
    required this.animalData,
  });

  @override
  List<Object?> get props => [animalId, animalData];
}

class DeleteAnimalEvent extends AnimalEvent {
  final String animalId;

  DeleteAnimalEvent(this.animalId);

  @override
  List<Object?> get props => [animalId];
}
