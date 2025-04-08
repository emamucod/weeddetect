import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'weeds.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // Users table (email/password only)
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');

        // Weeds table with user_email
        await db.execute('''
          CREATE TABLE weeds (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_email TEXT,
            name TEXT,
            height TEXT,
            danger_level TEXT,
            treatable TEXT,
            treatment_info TEXT,
            image_path TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        // Create dummy accounts
        await _createDummyAccounts(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE weeds ADD COLUMN user_email TEXT');
        }
        // Create dummy accounts if they don't exist when upgrading
        await _createDummyAccounts(db);
      },
    );
  }

  Future<void> _createDummyAccounts(Database db) async {
    // List of dummy accounts
    final dummyAccounts = [
      {'email': 'emamucod@example.com', 'password': 'password123'},
      {'email': 'jpmalveda@example.com', 'password': 'password123'},
      {'email': 'pjcatubig@example.com', 'password': 'password123'},
    ];

    // Insert each dummy account if it doesn't already exist
    for (var account in dummyAccounts) {
      try {
        await db.insert('users', {
          'email': account['email'],
          'password': account['password'],
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      } catch (e) {
        print('Error creating dummy account: $e');
      }
    }
  }

  // User methods
  Future<int> createUser(String email, String password) async {
    final db = await database;
    return await db.insert('users', {
      'email': email,
      'password': password, // Note: Hash this in production
    });
  }

  Future<Map<String, dynamic>?> authenticateUser(
    String email,
    String password,
  ) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Weed methods
  Future<int> insertWeed(
    Map<String, dynamic> weedData,
    String userEmail,
  ) async {
    final db = await database;
    return await db.insert('weeds', {...weedData, 'user_email': userEmail});
  }

  Future<List<Map<String, dynamic>>> getUserWeeds(String userEmail) async {
    final db = await database;
    return await db.query(
      'weeds',
      where: 'user_email = ?',
      whereArgs: [userEmail],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> deleteUserWeed(int weedId, String userEmail) async {
    final db = await database;
    await db.delete(
      'weeds',
      where: 'id = ? AND user_email = ?',
      whereArgs: [weedId, userEmail],
    );
  }

  // Utility methods
  Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, 'weeds.db');
  }
}
