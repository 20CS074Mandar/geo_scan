import 'dart:async';

import 'package:geo_scan/Models/checkpoint.dart';
import 'package:geo_scan/Models/scandata.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../Models/checkpoint.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    print("Initializing database and the path for it is " +
        await getDatabasesPath());
    String path = join(await getDatabasesPath(), 'checkpoint_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE checkpoints(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        checkpoint_name TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');
    await db.execute('''
    CREATE TABLE scandata(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      checkpoint_id INTEGER,
      timestamp TEXT,
      data TEXT,
      FOREIGN KEY (checkpoint_id) REFERENCES checkpoints (id)
    )
    ''');
  }

  // Insert checkpoint and ScanData
  Future<int> insertCheckpoint(Checkpoint checkpoint) async {
    Database db = await instance.database;
    return await db.insert('checkpoints', checkpoint.toMap());
  }

  Future<int> insertScanData(ScanData scanData) async {
    Database db = await instance.database;
    return await db.insert('scandata', scanData.toMap());
  }

  // Get methods
  Future<List<Checkpoint>> getCheckpoints() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('checkpoints');
    return List.generate(maps.length, (index) {
      return Checkpoint(
        id: maps[index]['id'],
        checkpoint_name: maps[index]['checkpoint_name'],
        latitude: maps[index]['latitude'],
        longitude: maps[index]['longitude'],
      );
    });
  }

  Future<List<ScanData>> getScannedData() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('scandata');
    return List.generate(maps.length, (index) {
      return ScanData(
        id: maps[index]['id'],
        checkpoint_id: maps[index]['checkpoint_id'],
        timestamp: maps[index]['timestamp'],
        data: maps[index]['data'],
      );
    });
  }

  Future<String> getCheckpointName(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps =
        await db.query('checkpoints', where: 'id = ?', whereArgs: [id]);
    return maps[0]['checkpoint_name'];
  }

  // Delete All Scanned Data
  Future<void> deleteAllScannedData() async {
    Database db = await instance.database;
    await db.delete('scandata');
  }
}
