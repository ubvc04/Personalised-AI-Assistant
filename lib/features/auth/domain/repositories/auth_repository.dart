import '../entities/user.dart';
import '../../../../core/utils/typedefs.dart';

abstract class AuthRepository {
  ResultFuture<User> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  });

  ResultFuture<User> signIn({
    required String email,
    required String password,
  });

  ResultVoid signOut();

  ResultFuture<User?> getCurrentUser();

  ResultVoid sendOTP({
    required String email,
    required String type, // 'signup', 'signin', 'reset'
  });

  ResultFuture<bool> verifyOTP({
    required String email,
    required String otp,
    required String type,
  });

  ResultVoid resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  });

  ResultVoid changePassword({
    required String currentPassword,
    required String newPassword,
  });

  ResultVoid updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarType,
    String? personality,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? settings,
  });

  ResultVoid deleteAccount();

  ResultFuture<bool> isEmailExists(String email);

  ResultVoid sendLoginAlert({
    required String email,
    required String deviceInfo,
    required String location,
    required DateTime timestamp,
  });

  ResultFuture<String> refreshToken();
}