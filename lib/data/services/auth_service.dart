import '../models/auth.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService({required this.apiClient});

  Future<LoginResponse> login(String email, String password) async {
    final requestBody = AuthRequest(
      email: email,
      password: password,
    ).toJson();

    final response = await apiClient.post('/api/auth/login', body: requestBody);
    return LoginResponse.fromJson(response);
  }

  Future<AuthResponse> verify2FA(String userId, String token) async {
    final requestBody = TwoFactorVerifyRequest(
      userId: userId,
      token: token,
    ).toJson();

    final response = await apiClient.post('/api/auth/2fa/verify', body: requestBody);
    return AuthResponse.fromJson(response);
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await apiClient.post('/api/auth/register', body: request.toJson());
    return AuthResponse.fromJson(response);
  }

  Future<User> getUserProfile() async {
    final response = await apiClient.get('/api/auth/profile');
    return User.fromJson(response);
  }

  Future<void> enable2FA() async {
    await apiClient.post('/api/auth/2fa/enable');
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final requestBody = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
    await apiClient.post('/api/users/change-password', body: requestBody);
  }

  Future<void> deactivateAccount() async {
    await apiClient.post('/api/users/deactivate');
  }

  // MÉTODO ACTUALIZADO: Solo envía los campos que se pueden actualizar
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
  }) async {
    // Preparar solo los datos que se pueden actualizar
    final requestBody = {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'address': address,
    };

    print('📤 AuthService sending data: $requestBody'); // Debug

    final response = await apiClient.put('/api/users/profile', body: requestBody);

    print('📥 AuthService received response: $response'); // Debug

    return User.fromJson(response);
  }

  // Método de compatibilidad que usa el objeto User completo
  Future<User> updateProfileWithUser(User user) async {
    return updateProfile(
      firstName: user.firstName,
      lastName: user.lastName,
      phoneNumber: user.phoneNumber,
      address: user.address,
    );
  }

  Future<void> logout() async {
    // Implement client-side logout
  }
}