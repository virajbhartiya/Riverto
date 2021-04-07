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
  static void dbSetup() async {
    WidgetsFlutterBinding.ensureInitialized();

    database = openDatabase(
      join(await getDatabasesPath(), 'recentlyPlayed.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE recent(title TEXT PRIMARY KEY, url TEXT,image TEXT,album TEXT,artist TEXT,lyrics TEXT,id TEXT)",
        );
      },
      version: 1,
    );
  }

  static Future<void> insertDog(RecentlyPlayed recent) async {
    final Database db = await database;
    await db.insert(
      'recent',
      recent.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<RecentlyPlayed>> recentlyPlayedList() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('recent');

    return List.generate(maps.length, (i) {
      return RecentlyPlayed(
          title: maps[i]['title'],
          url: maps[i]['url'],
          image: maps[i]['image'],
          album: maps[i]['album'],
          artist: maps[i]['artist'],
          lyrics: maps[i]['lyrics'],
          id: maps[i]['id']);
    });
  }

  static Future<void> deleteDbElement(String title) async {
    final db = await database;

    await db.delete(
      'recent',
      where: "title = ?",
      whereArgs: [title],
    );
  }

  static Future<List<RecentlyPlayed>> getSongs() async {
    return await Const.recentlyPlayedList();
  }

  static void change() async {
    recentSongs = await getSongs();
  }

  static List<RecentlyPlayed> recentSongs = [];
}
