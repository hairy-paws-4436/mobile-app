import 'package:equatable/equatable.dart';

abstract class NGOEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchNGOsEvent extends NGOEvent {}

class FetchNGODetailsEvent extends NGOEvent {
  final String ngoId;

  FetchNGODetailsEvent(this.ngoId);

  @override
  List<Object?> get props => [ngoId];
}

class FetchUserNGOEvent extends NGOEvent {}

class RegisterNGOEvent extends NGOEvent {
  final Map<String, dynamic> ngoData;
  final String? logoPath;

  RegisterNGOEvent({
    required this.ngoData,
    this.logoPath,
  });

  @override
  List<Object?> get props => [ngoData, logoPath];
}

class UpdateNGOEvent extends NGOEvent {
  final String ngoId;
  final Map<String, dynamic> ngoData;

  UpdateNGOEvent({
    required this.ngoId,
    required this.ngoData,
  });

  @override
  List<Object?> get props => [ngoId, ngoData];
}
