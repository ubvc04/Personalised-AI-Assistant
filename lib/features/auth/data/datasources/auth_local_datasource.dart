import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_utils.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearUser();
  Future<String?> getToken();
  Future<void> storeToken(String token);
  Future<void> clearToken();
  Future<String?> getRefreshToken();
  Future<void> storeRefreshToken(String refreshToken);
  Future<void> clearRefreshToken();
  Future<void> storeOTP(String email, String otp, String type);
  Future<String?> getOTP(String email, String type);
  Future<void> clearOTP(String email, String type);
  Future<bool> isOTPExpired(String email, String type);
  Future<void> storePasswordHash(String email, String passwordHash);
  Future<String?> getPasswordHash(String email);
  Future<bool> verifyPassword(String email, String password);
  Future<void> incrementLoginAttempts(String email);
  Future<int> getLoginAttempts(String email);
  Future<void> clearLoginAttempts(String email);
  Future<bool> isAccountLocked(String email);
  Future<void> lockAccount(String email);
  Future<void> unlockAccount(String email);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'current_user';
  
  final FlutterSecureStorage _secureStorage;
  final Box _authBox;
  final Box _otpBox;
  final Box _passwordBox;
  final Box _securityBox;

  AuthLocalDataSourceImpl({
    required FlutterSecureStorage secureStorage,
    required Box authBox,
    required Box otpBox,
    required Box passwordBox,
    required Box securityBox,
  }) : _secureStorage = secureStorage,
       _authBox = authBox,
       _otpBox = otpBox,
       _passwordBox = passwordBox,
       _securityBox = securityBox;

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = _authBox.get(_userKey);
      if (userJson != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(userJson));
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _authBox.put(_userKey, user.toJson());
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _authBox.delete(_userKey);
    } catch (e) {
      throw CacheException('Failed to clear user: ${e.toString()}');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      throw CacheException('Failed to get token: ${e.toString()}');
    }
  }

  @override
  Future<void> storeToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw CacheException('Failed to store token: ${e.toString()}');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw CacheException('Failed to clear token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      throw CacheException('Failed to get refresh token: ${e.toString()}');
    }
  }

  @override
  Future<void> storeRefreshToken(String refreshToken) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw CacheException('Failed to store refresh token: ${e.toString()}');
    }
  }

  @override
  Future<void> clearRefreshToken() async {
    try {
      await _secureStorage.delete(key: _refreshTokenKey);
    } catch (e) {
      throw CacheException('Failed to clear refresh token: ${e.toString()}');
    }
  }

  @override
  Future<void> storeOTP(String email, String otp, String type) async {
    try {
      final key = '${email}_${type}_otp';
      final data = {
        'otp': otp,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expires_at': DateTime.now().add(AppConstants.otpExpiration).millisecondsSinceEpoch,
      };
      await _otpBox.put(key, data);
    } catch (e) {
      throw CacheException('Failed to store OTP: ${e.toString()}');
    }
  }

  @override
  Future<String?> getOTP(String email, String type) async {
    try {
      final key = '${email}_${type}_otp';
      final data = _otpBox.get(key);
      if (data != null) {
        final expiresAt = DateTime.fromMillisecondsSinceEpoch(data['expires_at']);
        if (DateTime.now().isBefore(expiresAt)) {
          return data['otp'];
        } else {
          await clearOTP(email, type);
        }
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get OTP: ${e.toString()}');
    }
  }

  @override
  Future<void> clearOTP(String email, String type) async {
    try {
      final key = '${email}_${type}_otp';
      await _otpBox.delete(key);
    } catch (e) {
      throw CacheException('Failed to clear OTP: ${e.toString()}');
    }
  }

  @override
  Future<bool> isOTPExpired(String email, String type) async {
    try {
      final key = '${email}_${type}_otp';
      final data = _otpBox.get(key);
      if (data != null) {
        final expiresAt = DateTime.fromMillisecondsSinceEpoch(data['expires_at']);
        return DateTime.now().isAfter(expiresAt);
      }
      return true;
    } catch (e) {
      throw CacheException('Failed to check OTP expiration: ${e.toString()}');
    }
  }

  @override
  Future<void> storePasswordHash(String email, String passwordHash) async {
    try {
      await _passwordBox.put(email, passwordHash);
    } catch (e) {
      throw CacheException('Failed to store password hash: ${e.toString()}');
    }
  }

  @override
  Future<String?> getPasswordHash(String email) async {
    try {
      return _passwordBox.get(email);
    } catch (e) {
      throw CacheException('Failed to get password hash: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyPassword(String email, String password) async {
    try {
      final storedHash = await getPasswordHash(email);
      if (storedHash == null) return false;
      
      final inputHash = AppUtils.hashPassword(password);
      return storedHash == inputHash;
    } catch (e) {
      throw CacheException('Failed to verify password: ${e.toString()}');
    }
  }

  @override
  Future<void> incrementLoginAttempts(String email) async {
    try {
      final key = '${email}_login_attempts';
      final currentAttempts = _securityBox.get(key, defaultValue: 0);
      await _securityBox.put(key, currentAttempts + 1);
      
      // Check if account should be locked
      if (currentAttempts + 1 >= AppConstants.maxLoginAttempts) {
        await lockAccount(email);
      }
    } catch (e) {
      throw CacheException('Failed to increment login attempts: ${e.toString()}');
    }
  }

  @override
  Future<int> getLoginAttempts(String email) async {
    try {
      final key = '${email}_login_attempts';
      return _securityBox.get(key, defaultValue: 0);
    } catch (e) {
      throw CacheException('Failed to get login attempts: ${e.toString()}');
    }
  }

  @override
  Future<void> clearLoginAttempts(String email) async {
    try {
      final key = '${email}_login_attempts';
      await _securityBox.delete(key);
    } catch (e) {
      throw CacheException('Failed to clear login attempts: ${e.toString()}');
    }
  }

  @override
  Future<bool> isAccountLocked(String email) async {
    try {
      final key = '${email}_locked_until';
      final lockedUntil = _securityBox.get(key);
      if (lockedUntil != null) {
        final unlockTime = DateTime.fromMillisecondsSinceEpoch(lockedUntil);
        if (DateTime.now().isBefore(unlockTime)) {
          return true;
        } else {
          await unlockAccount(email);
        }
      }
      return false;
    } catch (e) {
      throw CacheException('Failed to check account lock status: ${e.toString()}');
    }
  }

  @override
  Future<void> lockAccount(String email) async {
    try {
      final key = '${email}_locked_until';
      final unlockTime = DateTime.now().add(AppConstants.lockoutDuration);
      await _securityBox.put(key, unlockTime.millisecondsSinceEpoch);
    } catch (e) {
      throw CacheException('Failed to lock account: ${e.toString()}');
    }
  }

  @override
  Future<void> unlockAccount(String email) async {
    try {
      final lockKey = '${email}_locked_until';
      final attemptsKey = '${email}_login_attempts';
      await _securityBox.delete(lockKey);
      await _securityBox.delete(attemptsKey);
    } catch (e) {
      throw CacheException('Failed to unlock account: ${e.toString()}');
    }
  }
}