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

  Future<User> login(String email, String password) async {
    try {
      final response = await authService.login(email, password);
      await _saveAuthData(response);
      return response.user;
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

  Future<void> verify2FA(String userId, String token) async {
    try {
      await authService.verify2FA(TwoFactorVerifyRequest(userId: userId, token: token));
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

  Future<User> updateProfile(User user) async {
    try {
      final updatedUser = await authService.updateProfile(user);
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
