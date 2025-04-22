import 'package:equatable/equatable.dart';

import '../../../data/models/ngo.dart';


abstract class NGOState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NGOInitial extends NGOState {}

class NGOLoading extends NGOState {}

class NGOsLoaded extends NGOState {
  final List<NGO> ngos;

  NGOsLoaded(this.ngos);

  @override
  List<Object?> get props => [ngos];
}

class NGODetailsLoaded extends NGOState {
  final NGO ngo;

  NGODetailsLoaded(this.ngo);

  @override
  List<Object?> get props => [ngo];
}

class UserNGOLoaded extends NGOState {
  final NGO ngo;

  UserNGOLoaded(this.ngo);

  @override
  List<Object?> get props => [ngo];
}

class NGORegistered extends NGOState {
  final NGO ngo;

  NGORegistered(this.ngo);

  @override
  List<Object?> get props => [ngo];
}

class NGOUpdated extends NGOState {
  final NGO ngo;

  NGOUpdated(this.ngo);

  @override
  List<Object?> get props => [ngo];
}

class NGOError extends NGOState {
  final String message;

  NGOError(this.message);

  @override
  List<Object?> get props => [message];
}
