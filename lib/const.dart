import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'Models/recentlyPlayed.dart';

class Const {
  static void setValues(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    await prefs.setBool("logIn", true);
  }

  static void logIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("logIn", true);
  }

  static Future<Database> database;
  static void db_setup() async {
    // Avoid errors caused by flutter upgrade.
// Importing 'package:flutter/widgets.dart' is required.
    WidgetsFlutterBinding.ensureInitialized();
// Open the database and store the reference.

    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'recentlyPlayed.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          "CREATE TABLE recent(title TEXT PRIMARY KEY, url TEXT,image TEXT,album TEXT,artist TEXT,lyrics TEXT)",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  Future<void> insertDog(RecentlyPlayed recent) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'recent',
      recent.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

List<RecentlyPlayed> recentSongs = [];
