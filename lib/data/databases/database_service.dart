import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';

class DatabaseService {
  static DatabaseService? _instance;
  Database? _database;
  
  // Hive boxes
  static Box<dynamic>? _userBox;
  static Box<dynamic>? _settingsBox;
  static Box<dynamic>? _conversationBox;
  static Box<dynamic>? _taskBox;
  static Box<dynamic>? _contactBox;
  static Box<dynamic>? _mediaBox;
  static Box<dynamic>? _authBox;
  static Box<dynamic>? _otpBox;
  static Box<dynamic>? _passwordBox;
  static Box<dynamic>? _securityBox;

  // Secure storage
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  // Initialize all databases
  Future<void> initialize() async {
    try {
      await _initializeHive();
      await _initializeSQLite();
    } catch (e) {
      throw DatabaseException('Failed to initialize databases: ${e.toString()}');
    }
  }

  // Initialize Hive database
  Future<void> _initializeHive() async {
    await Hive.initFlutter();
    
    // Open all required boxes
    _userBox = await Hive.openBox(AppConstants.userBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _conversationBox = await Hive.openBox(AppConstants.conversationBox);
    _taskBox = await Hive.openBox(AppConstants.taskBox);
    _contactBox = await Hive.openBox(AppConstants.contactBox);
    _mediaBox = await Hive.openBox(AppConstants.mediaBox);
    _authBox = await Hive.openBox('auth_box');
    _otpBox = await Hive.openBox('otp_box');
    _passwordBox = await Hive.openBox('password_box');
    _securityBox = await Hive.openBox('security_box');
  }

  // Initialize SQLite database
  Future<void> _initializeSQLite() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    _database = await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  // Create database tables
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        first_name TEXT,
        last_name TEXT,
        phone TEXT,
        avatar_url TEXT,
        avatar_type TEXT,
        personality TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_email_verified INTEGER DEFAULT 0,
        is_phone_verified INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        preferences TEXT,
        settings TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_archived INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        content TEXT NOT NULL,
        sender_type TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        message_type TEXT DEFAULT 'text',
        metadata TEXT,
        FOREIGN KEY (conversation_id) REFERENCES conversations (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date INTEGER,
        priority TEXT DEFAULT 'medium',
        status TEXT DEFAULT 'pending',
        category TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        completed_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        avatar_url TEXT,
        is_favorite INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE media_files (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        path TEXT NOT NULL,
        type TEXT NOT NULL,
        size INTEGER NOT NULL,
        duration INTEGER,
        thumbnail_path TEXT,
        created_at INTEGER NOT NULL,
        tags TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_pinned INTEGER DEFAULT 0,
        tags TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE calendar_events (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        location TEXT,
        reminder_time INTEGER,
        is_all_day INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE search_history (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        query TEXT NOT NULL,
        result_count INTEGER,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        UNIQUE(user_id, key)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_conversations_user_id ON conversations(user_id)');
    await db.execute('CREATE INDEX idx_messages_conversation_id ON messages(conversation_id)');
    await db.execute('CREATE INDEX idx_tasks_user_id ON tasks(user_id)');
    await db.execute('CREATE INDEX idx_contacts_user_id ON contacts(user_id)');
    await db.execute('CREATE INDEX idx_media_files_user_id ON media_files(user_id)');
    await db.execute('CREATE INDEX idx_notes_user_id ON notes(user_id)');
    await db.execute('CREATE INDEX idx_calendar_events_user_id ON calendar_events(user_id)');
    await db.execute('CREATE INDEX idx_search_history_user_id ON search_history(user_id)');
    await db.execute('CREATE INDEX idx_app_settings_user_id ON app_settings(user_id)');
  }

  // Handle database upgrades
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  // Getters for Hive boxes
  static Box<dynamic> get userBox {
    if (_userBox == null) {
      throw DatabaseException('User box not initialized');
    }
    return _userBox!;
  }

  static Box<dynamic> get settingsBox {
    if (_settingsBox == null) {
      throw DatabaseException('Settings box not initialized');
    }
    return _settingsBox!;
  }

  static Box<dynamic> get conversationBox {
    if (_conversationBox == null) {
      throw DatabaseException('Conversation box not initialized');
    }
    return _conversationBox!;
  }

  static Box<dynamic> get taskBox {
    if (_taskBox == null) {
      throw DatabaseException('Task box not initialized');
    }
    return _taskBox!;
  }

  static Box<dynamic> get contactBox {
    if (_contactBox == null) {
      throw DatabaseException('Contact box not initialized');
    }
    return _contactBox!;
  }

  static Box<dynamic> get mediaBox {
    if (_mediaBox == null) {
      throw DatabaseException('Media box not initialized');
    }
    return _mediaBox!;
  }

  static Box<dynamic> get authBox {
    if (_authBox == null) {
      throw DatabaseException('Auth box not initialized');
    }
    return _authBox!;
  }

  static Box<dynamic> get otpBox {
    if (_otpBox == null) {
      throw DatabaseException('OTP box not initialized');
    }
    return _otpBox!;
  }

  static Box<dynamic> get passwordBox {
    if (_passwordBox == null) {
      throw DatabaseException('Password box not initialized');
    }
    return _passwordBox!;
  }

  static Box<dynamic> get securityBox {
    if (_securityBox == null) {
      throw DatabaseException('Security box not initialized');
    }
    return _securityBox!;
  }

  // Getter for SQLite database
  Database get database {
    if (_database == null) {
      throw DatabaseException('SQLite database not initialized');
    }
    return _database!;
  }

  // Getter for secure storage
  static FlutterSecureStorage get secureStorage => _secureStorage;

  // Clear all user data (for sign out)
  Future<void> clearUserData(String userId) async {
    try {
      // Clear Hive boxes
      await _userBox?.clear();
      await _settingsBox?.clear();
      await _conversationBox?.clear();
      await _taskBox?.clear();
      await _contactBox?.clear();
      await _mediaBox?.clear();

      // Clear SQLite data for specific user
      await database.delete('users', where: 'id = ?', whereArgs: [userId]);
      await database.delete('conversations', where: 'user_id = ?', whereArgs: [userId]);
      await database.delete('tasks', where: 'user_id = ?', whereArgs: [userId]);
      await database.delete('contacts', where: 'user_id = ?', whereArgs: [userId]);
      await database.delete('media_files', where: 'user_id = ?', whereArgs: [userId]);
      await database.delete('notes', where: 'user_id = ?', whereArgs: [userId]);
      await database.delete('calendar_events', where: 'user_id = ?', whereArgs: [userId]);
      await database.delete('search_history', where: 'user_id = ?', whereArgs: [userId]);
      await database.delete('app_settings', where: 'user_id = ?', whereArgs: [userId]);

      // Clear secure storage
      await _secureStorage.deleteAll();
    } catch (e) {
      throw DatabaseException('Failed to clear user data: ${e.toString()}');
    }
  }

  // Export user data
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final userData = <String, dynamic>{};

      // Export from SQLite
      userData['users'] = await database.query('users', where: 'id = ?', whereArgs: [userId]);
      userData['conversations'] = await database.query('conversations', where: 'user_id = ?', whereArgs: [userId]);
      userData['tasks'] = await database.query('tasks', where: 'user_id = ?', whereArgs: [userId]);
      userData['contacts'] = await database.query('contacts', where: 'user_id = ?', whereArgs: [userId]);
      userData['media_files'] = await database.query('media_files', where: 'user_id = ?', whereArgs: [userId]);
      userData['notes'] = await database.query('notes', where: 'user_id = ?', whereArgs: [userId]);
      userData['calendar_events'] = await database.query('calendar_events', where: 'user_id = ?', whereArgs: [userId]);
      userData['search_history'] = await database.query('search_history', where: 'user_id = ?', whereArgs: [userId]);
      userData['app_settings'] = await database.query('app_settings', where: 'user_id = ?', whereArgs: [userId]);

      // Export from Hive (convert to Map)
      userData['hive_data'] = {
        'settings': _settingsBox?.toMap(),
        'conversations': _conversationBox?.toMap(),
        'tasks': _taskBox?.toMap(),
        'contacts': _contactBox?.toMap(),
        'media': _mediaBox?.toMap(),
      };

      return userData;
    } catch (e) {
      throw DatabaseException('Failed to export user data: ${e.toString()}');
    }
  }

  // Import user data
  Future<void> importUserData(Map<String, dynamic> userData) async {
    try {
      // This would implement data import functionality
      // For now, we'll keep it simple
      throw UnimplementedError('Import functionality not yet implemented');
    } catch (e) {
      throw DatabaseException('Failed to import user data: ${e.toString()}');
    }
  }

  // Close all databases
  Future<void> close() async {
    try {
      await _database?.close();
      await Hive.close();
    } catch (e) {
      throw DatabaseException('Failed to close databases: ${e.toString()}');
    }
  }
}