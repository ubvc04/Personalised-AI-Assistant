import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/databases/user_database.dart';
import '../../../../services/email_service.dart';
import '../../domain/entities/simple_user.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final EmailService _emailService;

  AuthNotifier(this._emailService) : super(AuthState());

  Future<void> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await UserDatabase.registerUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      // Send OTP email
      await _emailService.sendOTPEmail(
        email: email,
        otp: result['otp'],
        userName: name,
      );

      final user = User(
        id: result['id'].toString(),
        name: result['name'],
        email: result['email'],
        phone: result['phone'],
        isVerified: result['is_verified'],
      );

      state = state.copyWith(
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await UserDatabase.loginUser(
        email: email,
        password: password,
      );

      if (result != null) {
        final user = User(
          id: result['id'].toString(),
          name: result['name'],
          email: result['email'],
          phone: result['phone'],
          isVerified: result['is_verified'],
        );

        state = state.copyWith(
          user: user,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> verifyOTP({
    required String email,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await UserDatabase.verifyOTP(
        email: email,
        otp: otp,
      );

      // Update user verification status
      if (state.user != null) {
        final updatedUser = User(
          id: state.user!.id,
          name: state.user!.name,
          email: state.user!.email,
          phone: state.user!.phone,
          isVerified: true,
        );

        state = state.copyWith(
          user: updatedUser,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> resendOTP(String email) async {
    try {
      final otp = await UserDatabase.resendOTP(email);
      
      // Send new OTP email
      await _emailService.sendOTPEmail(
        email: email,
        otp: otp,
        userName: state.user?.name ?? 'User',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    state = AuthState();
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await UserDatabase.updateUserProfile(
        userId: int.parse(state.user!.id),
        name: name,
        phone: phone,
      );

      final updatedUser = User(
        id: state.user!.id,
        name: name ?? state.user!.name,
        email: state.user!.email,
        phone: phone ?? state.user!.phone,
        isVerified: state.user!.isVerified,
      );

      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await UserDatabase.changePassword(
        email: state.user!.email,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

final authProviderNew = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final emailService = EmailService();
  return AuthNotifier(emailService);
});