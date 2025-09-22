import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../../../core/utils/app_utils.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        user.hashCode ^
        errorMessage.hashCode ^
        isLoading.hashCode;
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final SendOTPUseCase _sendOTPUseCase;
  final VerifyOTPUseCase _verifyOTPUseCase;

  AuthNotifier({
    required SignUpUseCase signUpUseCase,
    required SignInUseCase signInUseCase,
    required SendOTPUseCase sendOTPUseCase,
    required VerifyOTPUseCase verifyOTPUseCase,
  }) : _signUpUseCase = signUpUseCase,
       _signInUseCase = signInUseCase,
       _sendOTPUseCase = sendOTPUseCase,
       _verifyOTPUseCase = verifyOTPUseCase,
       super(const AuthState());

  Future<void> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _signUpUseCase(SignUpParams(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(
            status: AuthStatus.error,
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (user) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isLoading: false,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
      AppUtils.debugError('Sign up error: ${e.toString()}');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _signInUseCase(SignInParams(
        email: email,
        password: password,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(
            status: AuthStatus.error,
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (user) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isLoading: false,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
      AppUtils.debugError('Sign in error: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      isLoading: true,
    );

    try {
      // Clear user state
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        errorMessage: 'Sign out failed: ${e.toString()}',
      );
      AppUtils.debugError('Sign out error: ${e.toString()}');
    }
  }

  Future<bool> sendOTP({
    required String email,
    required String type,
  }) async {
    try {
      final result = await _sendOTPUseCase(SendOTPParams(
        email: email,
        type: type,
      ));

      return result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: failure.message,
          );
          return false;
        },
        (_) => true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to send OTP: ${e.toString()}',
      );
      AppUtils.debugError('Send OTP error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> verifyOTP({
    required String email,
    required String otp,
    required String type,
  }) async {
    try {
      final result = await _verifyOTPUseCase(VerifyOTPParams(
        email: email,
        otp: otp,
        type: type,
      ));

      return result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: failure.message,
          );
          return false;
        },
        (isValid) => isValid,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to verify OTP: ${e.toString()}',
      );
      AppUtils.debugError('Verify OTP error: ${e.toString()}');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}