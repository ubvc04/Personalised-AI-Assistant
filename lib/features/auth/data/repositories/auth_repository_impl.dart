import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../core/utils/app_utils.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  ResultFuture<User> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      // Check if account is locked
      if (await localDataSource.isAccountLocked(email)) {
        return const Result.failure(
          AuthenticationFailure('Account is temporarily locked. Please try again later.'),
        );
      }

      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      // Store password hash locally
      final passwordHash = AppUtils.hashPassword(password);
      await localDataSource.storePasswordHash(email, passwordHash);

      // Cache user
      await localDataSource.cacheUser(user);

      // Clear any login attempts
      await localDataSource.clearLoginAttempts(email);

      return Result.success(user.toEntity());
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  ResultFuture<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Check if account is locked
      if (await localDataSource.isAccountLocked(email)) {
        return const Result.failure(
          AuthenticationFailure('Account is temporarily locked. Please try again later.'),
        );
      }

      // Verify password locally first
      final isValidPassword = await localDataSource.verifyPassword(email, password);
      if (!isValidPassword) {
        await localDataSource.incrementLoginAttempts(email);
        return const Result.failure(
          AuthenticationFailure('Invalid email or password'),
        );
      }

      final user = await remoteDataSource.signIn(
        email: email,
        password: password,
      );

      // Cache user
      await localDataSource.cacheUser(user);

      // Clear login attempts on successful login
      await localDataSource.clearLoginAttempts(email);

      return Result.success(user.toEntity());
    } on ValidationException catch (e) {
      await localDataSource.incrementLoginAttempts(email);
      return Result.failure(ValidationFailure(e.message));
    } on AuthenticationException catch (e) {
      await localDataSource.incrementLoginAttempts(email);
      return Result.failure(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  ResultVoid signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearUser();
      await localDataSource.clearToken();
      await localDataSource.clearRefreshToken();
      
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  ResultFuture<User?> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      return Result.success(cachedUser?.toEntity());
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  ResultVoid sendOTP({
    required String email,
    required String type,
  }) async {
    try {
      await remoteDataSource.sendOTP(email: email, type: type);
      
      // Store OTP locally for verification
      final otp = AppUtils.generateOTP();
      await localDataSource.storeOTP(email, otp, type);
      
      return const Result.success(null);
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  ResultFuture<bool> verifyOTP({
    required String email,
    required String otp,
    required String type,
  }) async {
    try {
      // Check if OTP is expired
      if (await localDataSource.isOTPExpired(email, type)) {
        return const Result.failure(
          ValidationFailure('OTP has expired. Please request a new one.'),
        );
      }

      // Verify OTP locally
      final storedOTP = await localDataSource.getOTP(email, type);
      if (storedOTP == null || storedOTP != otp) {
        return const Result.failure(ValidationFailure('Invalid OTP'));
      }

      // Verify with remote
      final isValid = await remoteDataSource.verifyOTP(
        email: email,
        otp: otp,
        type: type,
      );

      if (isValid) {
        await localDataSource.clearOTP(email, type);
      }

      return Result.success(isValid);
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  ResultVoid resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        email: email,
        newPassword: newPassword,
        otp: otp,
      );

      // Update password hash locally
      final passwordHash = AppUtils.hashPassword(newPassword);
      await localDataSource.storePasswordHash(email, passwordHash);

      // Clear OTP
      await localDataSource.clearOTP(email, 'reset');

      // Unlock account if it was locked
      await localDataSource.unlockAccount(email);

      return const Result.success(null);
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  ResultVoid changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      // Get current user
      final currentUser = await localDataSource.getCachedUser();
      if (currentUser == null) {
        return const Result.failure(
          AuthenticationFailure('User not found'),
        );
      }

      // Update password hash locally
      final passwordHash = AppUtils.hashPassword(newPassword);
      await localDataSource.storePasswordHash(currentUser.email, passwordHash);

      return const Result.success(null);
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on AuthenticationException catch (e) {
      return Result.failure(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  ResultVoid updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarType,
    String? personality,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final updatedUser = await remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        avatarType: avatarType,
        personality: personality,
        preferences: preferences,
        settings: settings,
      );

      // Cache updated user
      await localDataSource.cacheUser(updatedUser);

      return const Result.success(null);
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  ResultVoid deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      
      // Clear all local data
      await localDataSource.clearUser();
      await localDataSource.clearToken();
      await localDataSource.clearRefreshToken();

      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  ResultFuture<bool> isEmailExists(String email) async {
    try {
      final exists = await remoteDataSource.isEmailExists(email);
      return Result.success(exists);
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  ResultVoid sendLoginAlert({
    required String email,
    required String deviceInfo,
    required String location,
    required DateTime timestamp,
  }) async {
    try {
      await remoteDataSource.sendLoginAlert(
        email: email,
        deviceInfo: deviceInfo,
        location: location,
        timestamp: timestamp,
      );
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  ResultFuture<String> refreshToken() async {
    try {
      final newToken = await remoteDataSource.refreshToken();
      await localDataSource.storeToken(newToken);
      return Result.success(newToken);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}