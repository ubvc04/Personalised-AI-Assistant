import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class UserDatabase {
  static Database? _database;
  static const String _tableName = 'users';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ai_assistant_users.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
    );
  }

  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        is_verified INTEGER DEFAULT 0,
        otp_code TEXT,
        otp_expires_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create index for faster email lookups
    await db.execute('CREATE INDEX idx_email ON $_tableName(email)');
  }

  // User registration
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final db = await database;
    
    // Check if user already exists
    final existingUser = await db.query(
      _tableName,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    
    if (existingUser.isNotEmpty) {
      throw Exception('User with this email already exists');
    }
    
    // Hash password
    final passwordHash = _hashPassword(password);
    
    // Generate OTP
    final otp = _generateOTP();
    final otpExpiresAt = DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch;
    
    final userData = {
      'name': name,
      'email': email.toLowerCase(),
      'phone': phone,
      'password_hash': passwordHash,
      'is_verified': 0,
      'otp_code': otp,
      'otp_expires_at': otpExpiresAt,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    
    final userId = await db.insert(_tableName, userData);
    
    return {
      'id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'otp': otp,
      'is_verified': false,
    };
  }

  // User login
  static Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await database;
    
    final users = await db.query(
      _tableName,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    
    if (users.isEmpty) {
      throw Exception('User not found');
    }
    
    final user = users.first;
    final passwordHash = _hashPassword(password);
    
    if (user['password_hash'] != passwordHash) {
      throw Exception('Invalid password');
    }
    
    if (user['is_verified'] == 0) {
      throw Exception('Please verify your email before logging in');
    }
    
    // Update last login
    await db.update(
      _tableName,
      {'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [user['id']],
    );
    
    return {
      'id': user['id'],
      'name': user['name'],
      'email': user['email'],
      'phone': user['phone'],
      'is_verified': user['is_verified'] == 1,
    };
  }

  // Verify OTP
  static Future<bool> verifyOTP({
    required String email,
    required String otp,
  }) async {
    final db = await database;
    
    final users = await db.query(
      _tableName,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    
    if (users.isEmpty) {
      throw Exception('User not found');
    }
    
    final user = users.first;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (user['otp_code'] != otp) {
      throw Exception('Invalid OTP code');
    }
    
    if (user['otp_expires_at'] != null && now > user['otp_expires_at']) {
      throw Exception('OTP code has expired');
    }
    
    // Mark user as verified and clear OTP
    await db.update(
      _tableName,
      {
        'is_verified': 1,
        'otp_code': null,
        'otp_expires_at': null,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [user['id']],
    );
    
    return true;
  }

  // Resend OTP
  static Future<String> resendOTP(String email) async {
    final db = await database;
    
    final users = await db.query(
      _tableName,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    
    if (users.isEmpty) {
      throw Exception('User not found');
    }
    
    final otp = _generateOTP();
    final otpExpiresAt = DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch;
    
    await db.update(
      _tableName,
      {
        'otp_code': otp,
        'otp_expires_at': otpExpiresAt,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    
    return otp;
  }

  // Get user by ID
  static Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    
    final users = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (users.isEmpty) return null;
    
    final user = users.first;
    return {
      'id': user['id'],
      'name': user['name'],
      'email': user['email'],
      'phone': user['phone'],
      'is_verified': user['is_verified'] == 1,
      'created_at': user['created_at'],
    };
  }

  // Update user profile
  static Future<bool> updateUserProfile({
    required int userId,
    String? name,
    String? phone,
  }) async {
    final db = await database;
    
    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    
    if (name != null) updateData['name'] = name;
    if (phone != null) updateData['phone'] = phone;
    
    final result = await db.update(
      _tableName,
      updateData,
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    return result > 0;
  }

  // Change password
  static Future<bool> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    final db = await database;
    
    final users = await db.query(
      _tableName,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    
    if (users.isEmpty) {
      throw Exception('User not found');
    }
    
    final user = users.first;
    final oldPasswordHash = _hashPassword(oldPassword);
    
    if (user['password_hash'] != oldPasswordHash) {
      throw Exception('Current password is incorrect');
    }
    
    final newPasswordHash = _hashPassword(newPassword);
    
    final result = await db.update(
      _tableName,
      {
        'password_hash': newPasswordHash,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [user['id']],
    );
    
    return result > 0;
  }

  // Delete user account
  static Future<bool> deleteUser(int userId) async {
    final db = await database;
    
    final result = await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    return result > 0;
  }

  // Get all users (admin function)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    
    final users = await db.query(
      _tableName,
      columns: ['id', 'name', 'email', 'phone', 'is_verified', 'created_at'],
      orderBy: 'created_at DESC',
    );
    
    return users.map((user) => {
      'id': user['id'],
      'name': user['name'],
      'email': user['email'],
      'phone': user['phone'],
      'is_verified': user['is_verified'] == 1,
      'created_at': user['created_at'],
    }).toList();
  }

  // Helper methods
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password + 'ai_assistant_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String _generateOTP() {
    final random = Random();
    final otp = List.generate(6, (index) => random.nextInt(10)).join();
    return otp;
  }

  // Clear database (for testing)
  static Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(_tableName);
  }

  // Close database
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}