import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../../domain/entities/simple_user.dart';

class SimpleAuthNotifier extends StateNotifier<User?> {
  static const String _usersBoxName = 'users';
  static const String _currentUserKey = 'current_user';
  
  SimpleAuthNotifier() : super(null) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final box = await Hive.openBox(_usersBoxName);
      final userData = box.get(_currentUserKey);
      if (userData != null) {
        state = User.fromJson(Map<String, dynamic>.from(userData));
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final box = await Hive.openBox(_usersBoxName);
      
      // Check if user already exists
      final existingUser = box.get('user_$email');
      if (existingUser != null) {
        throw Exception('User with this email already exists');
      }
      
      // Create new user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: phone,
        isVerified: false, // Will be set to true after OTP verification
      );
      
      // Store user data
      await box.put('user_$email', user.toJson());
      
      // Generate and store OTP (simulate)
      final otp = _generateOTP();
      await box.put('otp_$email', {
        'code': otp,
        'expires': DateTime.now().add(Duration(minutes: 10)).millisecondsSinceEpoch,
      });
      
      state = user;
      
      // Simulate sending OTP email
      print('OTP sent to $email: $otp');
      
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final box = await Hive.openBox(_usersBoxName);
      
      // Get user data
      final userData = box.get('user_$email');
      if (userData == null) {
        throw Exception('User not found');
      }
      
      // For demo purposes, we'll skip password verification
      // In real app, you'd hash and compare passwords
      
      final user = User.fromJson(Map<String, dynamic>.from(userData));
      
      if (!user.isVerified) {
        throw Exception('Please verify your email before logging in');
      }
      
      // Store as current user
      await box.put(_currentUserKey, user.toJson());
      state = user;
      
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final box = await Hive.openBox(_usersBoxName);
      
      // Get stored OTP
      final otpData = box.get('otp_$email');
      if (otpData == null) {
        throw Exception('No OTP found for this email');
      }
      
      final otpInfo = Map<String, dynamic>.from(otpData);
      final storedOtp = otpInfo['code'];
      final expiresAt = otpInfo['expires'];
      
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        throw Exception('OTP has expired');
      }
      
      if (storedOtp != otp) {
        throw Exception('Invalid OTP');
      }
      
      // Mark user as verified
      final userData = box.get('user_$email');
      if (userData != null) {
        final user = User.fromJson(Map<String, dynamic>.from(userData));
        final verifiedUser = user.copyWith(isVerified: true);
        
        await box.put('user_$email', verifiedUser.toJson());
        await box.put(_currentUserKey, verifiedUser.toJson());
        await box.delete('otp_$email'); // Remove used OTP
        
        state = verifiedUser;
      }
      
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  Future<void> resendOTP(String email) async {
    try {
      final box = await Hive.openBox(_usersBoxName);
      
      // Generate new OTP
      final otp = _generateOTP();
      await box.put('otp_$email', {
        'code': otp,
        'expires': DateTime.now().add(Duration(minutes: 10)).millisecondsSinceEpoch,
      });
      
      // Simulate sending OTP email
      print('New OTP sent to $email: $otp');
      
    } catch (e) {
      throw Exception('Failed to resend OTP: $e');
    }
  }

  Future<void> logout() async {
    try {
      final box = await Hive.openBox(_usersBoxName);
      await box.delete(_currentUserKey);
      state = null;
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  String _generateOTP() {
    final random = Random();
    return List.generate(6, (index) => random.nextInt(10)).join();
  }
}

final simpleAuthProvider = StateNotifierProvider<SimpleAuthNotifier, User?>((ref) {
  return SimpleAuthNotifier();
});