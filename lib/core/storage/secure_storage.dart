import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage storage;

  SecureStorage({required this.storage});

  // Token
  Future<void> saveToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'token');
  }

  // User
  Future<void> saveUser(String userJson) async {
    await storage.write(key: 'user', value: userJson);
  }

  Future<String?> getUser() async {
    return await storage.read(key: 'user');
  }

  Future<void> deleteUser() async {
    await storage.delete(key: 'user');
  }

  // Clear all stored data
  Future<void> clearAll() async {
    await storage.deleteAll();
  }
}
