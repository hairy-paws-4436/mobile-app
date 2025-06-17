import 'dart:convert';

import '../../core/storage/secure_storage.dart';
import '../models/auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService authService;
  final SecureStorage secureStorage;

  AuthRepository({
    required this.authService,
    required this.secureStorage,
  });

  Future<bool> isLoggedIn() async {
    final token = await secureStorage.getToken();
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    final userJson = await secureStorage.getUser();
    if (userJson == null) return null;
    return User.fromJson(json.decode(userJson));
  }

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await authService.login(email, password);

      // Si no requiere 2FA, guarda los datos de sesión
      if (!response.requiresTwoFactor && response.token != null && response.user != null) {
        await _saveAuthData(AuthResponse(
          token: response.token!,
          user: response.user!,
        ));
      }

      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<User> register(RegisterRequest request) async {
    try {
      final response = await authService.register(request);
      await _saveAuthData(response);
      return response.user;
    } catch (e) {
      throw e;
    }
  }

  Future<void> enable2FA() async {
    try {
      await authService.enable2FA();
    } catch (e) {
      throw e;
    }
  }

  Future<User> verify2FA(String userId, String token) async {
    try {
      final response = await authService.verify2FA(userId, token);
      await _saveAuthData(response);
      return response.user;
    } catch (e) {
      throw e;
    }
  }

  Future<User> getUserProfile() async {
    try {
      final user = await authService.getUserProfile();
      await secureStorage.saveUser(json.encode(user.toJson()));
      return user;
    } catch (e) {
      throw e;
    }
  }

  // Método actualizado para usar datos específicos del perfil
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      print('🔄 AuthRepository calling authService.updateProfile'); // Debug

      final updatedUser = await authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
      );

      print('✅ AuthRepository received updated user: ${updatedUser.firstName} ${updatedUser.lastName}'); // Debug

      await secureStorage.saveUser(json.encode(updatedUser.toJson()));
      return updatedUser;
    } catch (e) {
      print('❌ AuthRepository error: $e'); // Debug
      throw e;
    }
  }

  // Mantener el método original por compatibilidad
  Future<User> updateProfileWithUser(User user) async {
    try {
      final updatedUser = await authService.updateProfileWithUser(user);
      await secureStorage.saveUser(json.encode(updatedUser.toJson()));
      return updatedUser;
    } catch (e) {
      throw e;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await authService.changePassword(currentPassword, newPassword);
    } catch (e) {
      throw e;
    }
  }

  Future<void> deactivateAccount() async {
    try {
      await authService.deactivateAccount();
      await logout();
    } catch (e) {
      throw e;
    }
  }

  Future<void> logout() async {
    await secureStorage.clearAll();
  }

  Future<void> _saveAuthData(AuthResponse response) async {
    await secureStorage.saveToken(response.token);
    await secureStorage.saveUser(json.encode(response.user.toJson()));
  }
}