import '../../../data/models/auth.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<Enable2FAEvent>(_onEnable2FA);
    on<Verify2FAEvent>(_onVerify2FA);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordEvent>(_onChangePassword);
    on<DeactivateAccountEvent>(_onDeactivateAccount);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          final fetchedUser = await authRepository.getUserProfile();
          emit(Authenticated(user: fetchedUser));
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogin(
      LoginEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.login(event.email, event.password);

      // Verificar si requiere autenticación de dos factores
      if (response.requiresTwoFactor) {
        emit(RequiresTwoFactor(userId: response.userId!));
      } else {
        // Login normal
        emit(Authenticated(user: response.user!));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onVerify2FA(
      Verify2FAEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.verify2FA(event.userId, event.token);
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onRegister(
      RegisterEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final registerRequest = RegisterRequest(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
        role: event.role,
        address: event.address,
        identityDocument: event.identityDocument,
      );

      final user = await authRepository.register(registerRequest);
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      // Verificar que el usuario esté autenticado
      final currentUser = await authRepository.getCurrentUser();
      if (currentUser == null) {
        emit(AuthError(message: 'User not found. Please login again.'));
        return;
      }

      print('🔄 Updating profile for user: ${currentUser.email}');
      print('🔄 Current user data: ${currentUser.firstName} ${currentUser.lastName} - ${currentUser.phoneNumber}');
      print('🔄 New data: ${event.firstName.trim()}, ${event.lastName.trim()}, ${event.phoneNumber.trim()}, ${event.address.trim()}');

      // Validar datos antes de enviar
      final firstName = event.firstName.trim();
      final lastName = event.lastName.trim();
      final phoneNumber = event.phoneNumber.trim();
      final address = event.address.trim();

      if (firstName.isEmpty || lastName.isEmpty || phoneNumber.isEmpty || address.isEmpty) {
        emit(AuthError(message: 'All fields are required'));
        return;
      }

      // Validar formato del teléfono peruano (9 dígitos)
      if (!RegExp(r'^\d{9}$').hasMatch(phoneNumber)) {
        emit(AuthError(message: 'Phone number must be exactly 9 digits'));
        return;
      }

      // Usar el nuevo método del repository
      final result = await authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
      );

      print('✅ Profile updated successfully: ${result.firstName} ${result.lastName} - ${result.phoneNumber}');

      emit(ProfileUpdateSuccess(user: result));
      // Emitir el estado autenticado después de un breve delay para que se vea el mensaje de éxito
      await Future.delayed(const Duration(milliseconds: 500));
      emit(Authenticated(user: result));
    } catch (e) {
      print('❌ Error updating profile in bloc: $e');

      // Extraer mensaje de error más limpio
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      emit(AuthError(message: errorMessage));

      // Volver al estado autenticado después del error
      final currentUser = await authRepository.getCurrentUser();
      if (currentUser != null) {
        await Future.delayed(const Duration(milliseconds: 2000));
        emit(Authenticated(user: currentUser));
      }
    }
  }

  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onEnable2FA(
      Enable2FAEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      await authRepository.enable2FA();
      emit(Enable2FASuccess());

      // Refresh user state
      final user = await authRepository.getUserProfile();
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }



  Future<void> _onChangePassword(
      ChangePasswordEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      await authRepository.changePassword(
        event.currentPassword,
        event.newPassword,
      );
      emit(PasswordChangeSuccess());

      // Return to authenticated state
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user: user));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onDeactivateAccount(
      DeactivateAccountEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      await authRepository.deactivateAccount();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
