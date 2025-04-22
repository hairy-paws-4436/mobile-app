import '../../../data/models/user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class Enable2FASuccess extends AuthState {}

class PasswordChangeSuccess extends AuthState {}

class ProfileUpdateSuccess extends AuthState {
  final User user;

  ProfileUpdateSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}
