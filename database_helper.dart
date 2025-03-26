import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:typed_data';
import 'user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, "auth.db");
      print("Database path: $path");
      var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
      print("Database initialized successfully");
      return theDb;
    } catch (e) {
      print("Database initialization error: $e");
      throw e;
    }
  }

  void _onCreate(Database db, int version) async {
    try {
      await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        city TEXT NOT NULL,
        gender TEXT NOT NULL,
        address TEXT NOT NULL,
        image BLOB
      )
    ''');
      print("Table created successfully");
    } catch (e) {
      print("Table creation error: $e");
      throw e;
    }
  }

  Future<int> saveUser(Map<String, dynamic> user) async {
    try {
      var dbClient = await db;
      print("Attempting to save user: ${user['username']}");
      // Print the keys to debug
      print("User map keys: ${user.keys.toList()}");
      int id = await dbClient.insert("users", user);
      print("User saved with ID: $id");
      return id;
    } catch (e) {
      print("Error saving user: $e");
      throw e;
    }
  }

  Future<int> deleteUser(int id) async {
    try {
      var dbClient = await db;
      int result = await dbClient.delete(
        "users",
        where: "id = ?",
        whereArgs: [id],
      );
      print("Deleted $result user(s) with ID: $id");
      return result;
    } catch (e) {
      print("Error deleting user: $e");
      throw e;
    }
  }

  Future<bool> isUserExists(String username) async {
    try {
      var dbClient = await db;
      var res = await dbClient.query("users",
          where: "username = ?", whereArgs: [username]);
      return res.isNotEmpty;
    } catch (e) {
      print("Error checking if user exists: $e");
      throw e;
    }
  }

  Future<Map<String, dynamic>?> getLoginUser(String username, String password) async {
    try {
      var dbClient = await db;
      var res = await dbClient.query("users",
          where: "username = ? AND password = ?",
          whereArgs: [username, password]);

      if (res.isNotEmpty) {
        return res.first;
      }
      return null;
    } catch (e) {
      print("Error getting login user: $e");
      throw e;
    }
  }

  // Add this to your DatabaseHelper class
  Future<List<User>> getAllUsers() async {
    try {
      var dbClient = await db;
      var res = await dbClient.query("users");
      return res.map((user) => User.fromMap(user)).toList();
    } catch (e) {
      print("Error getting all users: $e");
      throw e;
    }
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      var dbClient = await db;
      var res = await dbClient.query("users",
          where: "username = ?", whereArgs: [username]);

      if (res.isNotEmpty) {
        return res.first;
      }
      return null;
    } catch (e) {
      print("Error getting user by username: $e");
      throw e;
    }
  }
}