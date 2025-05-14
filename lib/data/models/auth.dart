import 'package:mobile_app/data/models/user.dart';

// Agregar una nueva clase para la respuesta inicial de login
class LoginResponse {
  final String? token;
  final User? user;
  final bool requiresTwoFactor;
  final String? userId;

  LoginResponse({
    this.token,
    this.user,
    this.requiresTwoFactor = false,
    this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Verificar si requiere 2FA
    if (json['requiresTwoFactor'] == true) {
      return LoginResponse(
        requiresTwoFactor: true,
        userId: json['userId'] ?? '',
      );
    }

    // Caso normal (sin 2FA)
    return LoginResponse(
      token: json['access_token'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      requiresTwoFactor: false,
    );
  }
}

class AuthRequest {
  final String email;
  final String password;

  AuthRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String identityDocument;
  final String role;
  final String address;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.identityDocument,
    required this.role,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'identityDocument': identityDocument,
      'role': role,
      'address': address,
    };
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['access_token'],
      user: User.fromJson(json['user']),
    );
  }
}

class TwoFactorVerifyRequest {
  final String userId;
  final String token;

  TwoFactorVerifyRequest({
    required this.userId,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'token': token,
    };
  }
}