import 'package:equatable/equatable.dart';
import '../../../data/models/animal.dart';

abstract class AnimalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnimalInitial extends AnimalState {}

class AnimalLoading extends AnimalState {}

class AnimalsLoaded extends AnimalState {
  final List<Animal> animals;

  AnimalsLoaded(this.animals);

  @override
  List<Object?> get props => [animals];
}

class OwnerAnimalsLoaded extends AnimalState {
  final List<Animal> animals;

  OwnerAnimalsLoaded(this.animals);

  @override
  List<Object?> get props => [animals];
}

class AnimalDetailsLoaded extends AnimalState {
  final Animal animal;

  AnimalDetailsLoaded(this.animal);

  @override
  List<Object?> get props => [animal];
}

class AnimalCreated extends AnimalState {
  final Animal animal;

  AnimalCreated(this.animal);

  @override
  List<Object?> get props => [animal];
}

class AnimalUpdated extends AnimalState {
  final Animal animal;

  AnimalUpdated(this.animal);

  @override
  List<Object?> get props => [animal];
}

class AnimalDeleted extends AnimalState {}

class AnimalError extends AnimalState {
  final String message;

  AnimalError(this.message);

  @override
  List<Object?> get props => [message];
}
