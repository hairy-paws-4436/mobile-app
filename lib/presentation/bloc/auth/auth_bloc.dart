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

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      // Get current user first
      final currentUser = await authRepository.getCurrentUser();
      if (currentUser == null) {
        emit(AuthError(message: 'User not found'));
        return;
      }

      // Update with new values
      final updatedUser = User(
        id: currentUser.id,
        email: currentUser.email,
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
        role: currentUser.role,
        address: event.address,
        is2faEnabled: currentUser.is2faEnabled,
      );

      final result = await authRepository.updateProfile(updatedUser);
      emit(ProfileUpdateSuccess(user: result));
      emit(Authenticated(user: result));
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
