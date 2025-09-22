import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';

class DatabaseService {
  static const String _databaseName = 'nextstep.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String usersTable = 'users';
  static const String settingsTable = 'settings';

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Future<void> initialize() async {
    // Access the instance and ensure database is initialized
    final db = await _instance.database;
    print('Database initialized successfully at: ${db.path}');
  }

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE $usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT UNIQUE,
        email TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        avatar_url TEXT,
        bio TEXT,
        location TEXT,
        phone TEXT,
        linkedin_url TEXT,
        website_url TEXT,
        graduation_year TEXT,
        roll_number TEXT,
        company TEXT,
        current_position TEXT,
        education TEXT,
        skills TEXT, -- JSON array
        interests TEXT, -- JSON array
        achievements TEXT, -- JSON array
        is_google_login INTEGER DEFAULT 0,
        google_id TEXT UNIQUE,
        last_login TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create settings table for app preferences
    await db.execute('''
      CREATE TABLE $settingsTable (
        key TEXT PRIMARY KEY,
        value TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Insert default settings
    await db.insert(settingsTable, {'key': 'auto_login_enabled', 'value': 'true'});
    await db.insert(settingsTable, {'key': 'notifications_enabled', 'value': 'true'});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here if needed
  }

  // User Management Methods
  Future<int> insertOrUpdateUser(UserModel user) async {
    final db = await database;
    final userMap = user.toMap();

    // Add timestamps
    userMap['updated_at'] = DateTime.now().toIso8601String();

    final existing = await db.query(
      usersTable,
      where: 'email = ?',
      whereArgs: [user.email],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      // Update existing user
      return await db.update(
        usersTable,
        userMap,
        where: 'email = ?',
        whereArgs: [user.email],
      );
    } else {
      // Insert new user
      userMap['created_at'] = DateTime.now().toIso8601String();
      return await db.insert(usersTable, userMap);
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      usersTable,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserByGoogleId(String googleId) async {
    final db = await database;
    final maps = await db.query(
      usersTable,
      where: 'google_id = ?',
      whereArgs: [googleId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getLastLoggedInUser() async {
    final db = await database;
    final maps = await db.query(
      usersTable,
      orderBy: 'last_login DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateLastLogin(String email) async {
    final db = await database;
    await db.update(
      usersTable,
      {
        'last_login': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String()
      },
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<void> setGoogleLoginInfo(String email, String googleId) async {
    final db = await database;
    await db.update(
      usersTable,
      {
        'is_google_login': 1,
        'google_id': googleId,
        'updated_at': DateTime.now().toIso8601String()
      },
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // Settings Management Methods
  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query(
      settingsTable,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      settingsTable,
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String()
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> setBulkUserData(String email, Map<String, dynamic> data) async {
    final db = await database;

    final updateData = Map<String, dynamic>.from(data);
    updateData['updated_at'] = DateTime.now().toIso8601String();

    await db.update(
      usersTable,
      updateData,
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<Map<String, dynamic>?> getUserBulkData(String email) async {
    final db = await database;
    final maps = await db.query(
      usersTable,
      columns: [
        'name',
        'email',
        'role',
        'avatar_url',
        'bio',
        'location',
        'phone',
        'linkedin_url',
        'website_url',
        'graduation_year',
        'roll_number',
        'company',
        'current_position',
        'education',
        'skills',
        'interests',
        'achievements',
        'is_google_login',
        'last_login'
      ],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers({int limit = 50, int offset = 0}) async {
    final db = await database;
    final maps = await db.query(
      usersTable,
      limit: limit,
      offset: offset,
      orderBy: 'name ASC',
    );

    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $usersTable');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Cleanup Methods
  Future<void> deleteUser(String email) async {
    final db = await database;
    await db.delete(
      usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<void> clearAllUsers() async {
    final db = await database;
    await db.delete(usersTable);
  }

  Future<void> clearAllSettings() async {
    final db = await database;
    await db.delete(settingsTable);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
