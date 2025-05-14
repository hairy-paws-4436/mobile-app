abstract class AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String identityDocument;
  final String role;
  final String address;

  RegisterEvent({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.identityDocument,
    required this.role,
    required this.address,
  });
}

class LogoutEvent extends AuthEvent {}

class Enable2FAEvent extends AuthEvent {}

class Verify2FAEvent extends AuthEvent {
  final String userId;
  final String token;

  Verify2FAEvent({required this.userId, required this.token});
}

class UpdateProfileEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String address;

  UpdateProfileEvent({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.address,
  });
}

class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });
}

class DeactivateAccountEvent extends AuthEvent {}
