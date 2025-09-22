import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'dart:math';

class AppUtils {
  // Date and Time Utilities
  static String formatDate(DateTime date, {String pattern = 'MMM dd, yyyy'}) {
    return DateFormat(pattern).format(date);
  }
  
  static String formatTime(DateTime time, {bool is24Hour = false}) {
    return DateFormat(is24Hour ? 'HH:mm' : 'hh:mm a').format(time);
  }
  
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (dateToCheck == today) {
      return 'Today ${formatTime(dateTime)}';
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${formatTime(dateTime)}';
    } else if (now.difference(dateTime).inDays < 7) {
      return '${DateFormat('EEEE').format(dateTime)} ${formatTime(dateTime)}';
    } else {
      return '${formatDate(dateTime)} ${formatTime(dateTime)}';
    }
  }
  
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }
  
  // String Utilities
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  static String capitalizeWords(String text) {
    return text.split(' ').map(capitalize).join(' ');
  }
  
  static String truncateString(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
  
  static String removeHtmlTags(String htmlString) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlString.replaceAll(regex, '');
  }
  
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
  
  // Validation Utilities
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }
  
  static bool isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$').hasMatch(password);
  }
  
  static bool isValidUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }
  
  // Security Utilities
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  static String generateOTP({int length = 6}) {
    final random = Random();
    String otp = '';
    for (int i = 0; i < length; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }
  
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           generateRandomString(6);
  }
  
  // File Utilities
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }
  
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }
  
  static bool isVideoFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv'].contains(extension);
  }
  
  static bool isAudioFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['mp3', 'wav', 'aac', 'ogg', 'wma', 'm4a', 'flac'].contains(extension);
  }
  
  static bool isDocumentFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(extension);
  }
  
  // Number Utilities
  static String formatNumber(num number, {int decimalPlaces = 0}) {
    return NumberFormat('#,##0${decimalPlaces > 0 ? '.' + '0' * decimalPlaces : ''}').format(number);
  }
  
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${formatNumber(amount, decimalPlaces: 2)}';
  }
  
  static String formatPercentage(double value, {int decimalPlaces = 1}) {
    return '${(value * 100).toStringAsFixed(decimalPlaces)}%';
  }
  
  // Color Utilities
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
  
  // Platform Utilities
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static bool get isWeb => kIsWeb;
  
  // List Utilities
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }
  
  static List<List<T>> chunk<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }
  
  // Debug Utilities
  static void debugLog(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      print('[$tag] ${DateTime.now()}: $message');
    }
  }
  
  static void debugError(String error, {String tag = 'ERROR', StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('[$tag] ${DateTime.now()}: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }
  
  // Performance Utilities
  static Future<T> measureTime<T>(Future<T> Function() function, {String? label}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      stopwatch.stop();
      if (label != null) {
        debugLog('$label took ${stopwatch.elapsedMilliseconds}ms', tag: 'PERFORMANCE');
      }
      return result;
    } catch (e) {
      stopwatch.stop();
      if (label != null) {
        debugLog('$label failed after ${stopwatch.elapsedMilliseconds}ms', tag: 'PERFORMANCE');
      }
      rethrow;
    }
  }
  
  // Device Utilities
  static Future<String> getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
  
  // Network Utilities
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }
  
  // Animation Utilities
  static Duration getDynamicDuration(double distance, {double baseSpeed = 1000}) {
    final duration = (distance / baseSpeed * 1000).round();
    return Duration(milliseconds: duration.clamp(200, 1000));
  }
}

// Extension methods for convenience
extension StringExtensions on String {
  String get capitalize => AppUtils.capitalize(this);
  String get capitalizeWords => AppUtils.capitalizeWords(this);
  String truncate(int maxLength, {String suffix = '...'}) => 
    AppUtils.truncateString(this, maxLength, suffix: suffix);
  bool get isValidEmail => AppUtils.isValidEmail(this);
  bool get isValidPhone => AppUtils.isValidPhone(this);
  bool get isValidPassword => AppUtils.isValidPassword(this);
  bool get isValidUrl => AppUtils.isValidUrl(this);
  String get removeHtmlTags => AppUtils.removeHtmlTags(this);
  String get fileExtension => AppUtils.getFileExtension(this);
  bool get isImageFile => AppUtils.isImageFile(this);
  bool get isVideoFile => AppUtils.isVideoFile(this);
  bool get isAudioFile => AppUtils.isAudioFile(this);
  bool get isDocumentFile => AppUtils.isDocumentFile(this);
}

extension DateTimeExtensions on DateTime {
  String format({String pattern = 'MMM dd, yyyy'}) => AppUtils.formatDate(this, pattern: pattern);
  String get formatTime => AppUtils.formatTime(this);
  String get formatDateTime => AppUtils.formatDateTime(this);
  String get timeAgo => AppUtils.timeAgo(this);
}

extension NumExtensions on num {
  String formatNumber({int decimalPlaces = 0}) => AppUtils.formatNumber(this, decimalPlaces: decimalPlaces);
  String formatCurrency({String symbol = '\$'}) => AppUtils.formatCurrency(toDouble(), symbol: symbol);
  String get formatFileSize => AppUtils.formatFileSize(toInt());
}

extension DoubleExtensions on double {
  String formatPercentage({int decimalPlaces = 1}) => AppUtils.formatPercentage(this, decimalPlaces: decimalPlaces);
}

extension ListExtensions<T> on List<T> {
  List<T> get removeDuplicates => AppUtils.removeDuplicates(this);
  List<List<T>> chunk(int size) => AppUtils.chunk(this, size);
}