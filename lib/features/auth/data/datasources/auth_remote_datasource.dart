import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../services/email_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendOTP({
    required String email,
    required String type,
  });

  Future<bool> verifyOTP({
    required String email,
    required String otp,
    required String type,
  });

  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarType,
    String? personality,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? settings,
  });

  Future<void> deleteAccount();

  Future<bool> isEmailExists(String email);

  Future<void> sendLoginAlert({
    required String email,
    required String deviceInfo,
    required String location,
    required DateTime timestamp,
  });

  Future<String> refreshToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final EmailService _emailService;

  AuthRemoteDataSourceImpl({
    required EmailService emailService,
  }) : _emailService = emailService;

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      // Validate input
      if (!email.isValidEmail) {
        throw const ValidationException('Invalid email format');
      }
      
      if (!password.isValidPassword) {
        throw const ValidationException(
          'Password must be at least 8 characters with uppercase, lowercase, and number'
        );
      }

      // Check if email already exists
      if (await isEmailExists(email)) {
        throw const ValidationException('Email already exists');
      }

      // Create user
      final user = UserModel(
        id: AppUtils.generateUniqueId(),
        email: email,
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: false,
        preferences: _getDefaultPreferences(),
        settings: _getDefaultSettings(),
      );

      // Send welcome email
      await _emailService.sendWelcomeEmail(
        toEmail: email,
        userName: user.displayName,
      );

      return user;
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (!email.isValidEmail) {
        throw const ValidationException('Invalid email format');
      }

      if (password.isEmpty) {
        throw const ValidationException('Password is required');
      }

      // For demo purposes, we'll create a mock user
      // In a real app, this would authenticate against a backend
      final user = UserModel(
        id: AppUtils.generateUniqueId(),
        email: email,
        firstName: 'Demo',
        lastName: 'User',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        isEmailVerified: true,
        preferences: _getDefaultPreferences(),
        settings: _getDefaultSettings(),
      );

      // Send login alert
      await _sendLoginAlert(email);

      return user;
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // In a real app, this would invalidate tokens on the server
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw ServerException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendOTP({
    required String email,
    required String type,
  }) async {
    try {
      if (!email.isValidEmail) {
        throw const ValidationException('Invalid email format');
      }

      final otp = AppUtils.generateOTP();
      
      await _emailService.sendOTPEmail(
        toEmail: email,
        otp: otp,
        type: type,
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException('Failed to send OTP: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyOTP({
    required String email,
    required String otp,
    required String type,
  }) async {
    try {
      if (!email.isValidEmail) {
        throw const ValidationException('Invalid email format');
      }

      if (otp.length != 6 || !RegExp(r'^\d+$').hasMatch(otp)) {
        throw const ValidationException('Invalid OTP format');
      }

      // For demo purposes, accept any 6-digit OTP
      // In a real app, this would verify against stored OTP
      return otp.length == 6 && RegExp(r'^\d+$').hasMatch(otp);
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException('OTP verification failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  }) async {
    try {
      if (!email.isValidEmail) {
        throw const ValidationException('Invalid email format');
      }

      if (!newPassword.isValidPassword) {
        throw const ValidationException(
          'Password must be at least 8 characters with uppercase, lowercase, and number'
        );
      }

      // Verify OTP first
      final isValidOTP = await verifyOTP(
        email: email,
        otp: otp,
        type: 'reset',
      );

      if (!isValidOTP) {
        throw const ValidationException('Invalid OTP');
      }

      // In a real app, this would update the password on the server
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (currentPassword.isEmpty) {
        throw const ValidationException('Current password is required');
      }

      if (!newPassword.isValidPassword) {
        throw const ValidationException(
          'New password must be at least 8 characters with uppercase, lowercase, and number'
        );
      }

      if (currentPassword == newPassword) {
        throw const ValidationException('New password must be different from current password');
      }

      // In a real app, this would verify current password and update on server
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException('Password change failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarType,
    String? personality,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? settings,
  }) async {
    try {
      // Validate phone if provided
      if (phone != null && phone.isNotEmpty && !phone.isValidPhone) {
        throw const ValidationException('Invalid phone number format');
      }

      // In a real app, this would update the user profile on the server
      await Future.delayed(const Duration(milliseconds: 500));

      // Return updated user (mock)
      return UserModel(
        id: AppUtils.generateUniqueId(),
        email: 'user@example.com',
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        avatarType: avatarType,
        personality: personality,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        isEmailVerified: true,
        preferences: preferences ?? _getDefaultPreferences(),
        settings: settings ?? _getDefaultSettings(),
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException('Profile update failed: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      // In a real app, this would delete the account on the server
      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      throw ServerException('Account deletion failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> isEmailExists(String email) async {
    try {
      if (!email.isValidEmail) {
        throw const ValidationException('Invalid email format');
      }

      // In a real app, this would check against the server
      await Future.delayed(const Duration(milliseconds: 300));
      
      // For demo purposes, return false (email doesn't exist)
      return false;
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException('Email check failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendLoginAlert({
    required String email,
    required String deviceInfo,
    required String location,
    required DateTime timestamp,
  }) async {
    try {
      await _emailService.sendLoginAlert(
        toEmail: email,
        deviceInfo: deviceInfo,
        location: location,
        timestamp: timestamp,
      );
    } catch (e) {
      // Don't throw here as login should succeed even if alert fails
      AppUtils.debugError('Failed to send login alert: ${e.toString()}');
    }
  }

  @override
  Future<String> refreshToken() async {
    try {
      // In a real app, this would refresh the token on the server
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return mock token
      return 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw ServerException('Token refresh failed: ${e.toString()}');
    }
  }

  Future<void> _sendLoginAlert(String email) async {
    try {
      final deviceInfo = await _getDeviceInfo();
      final location = await _getLocation();
      
      await sendLoginAlert(
        email: email,
        deviceInfo: deviceInfo,
        location: location,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Don't throw here as login should succeed even if alert fails
      AppUtils.debugError('Failed to send login alert: ${e.toString()}');
    }
  }

  Future<String> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model} (Android ${androidInfo.version.release})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name} (iOS ${iosInfo.systemVersion})';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      return 'Unknown Device';
    }
  }

  Future<String> _getLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );

        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          return '${place.locality}, ${place.country}';
        }
      }
      
      return 'Unknown Location';
    } catch (e) {
      return 'Unknown Location';
    }
  }

  Map<String, dynamic> _getDefaultPreferences() {
    return {
      'theme': 'system',
      'language': 'en-US',
      'notifications': true,
      'voice_enabled': true,
      'avatar_type': 'female',
      'personality': 'friendly',
      'speech_rate': 0.8,
      'speech_pitch': 1.0,
    };
  }

  Map<String, dynamic> _getDefaultSettings() {
    return {
      'auto_backup': true,
      'sync_enabled': true,
      'analytics_enabled': true,
      'crash_reporting': true,
      'location_enabled': false,
      'biometric_enabled': false,
      'two_factor_enabled': false,
    };
  }
}