import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'alarms.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE alarms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            city TEXT,
            prayer TEXT,
            date TEXT,
            time TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertAlarm(Map<String, dynamic> alarm) async {
    final db = await database;
    return await db.insert('alarms', alarm);
  }

  Future<List<Map<String, dynamic>>> getAlarms() async {
    final db = await database;
    return await db.query('alarms', orderBy: 'id DESC');
  }

  Future<int> deleteAlarm(int id) async {
    final db = await database;
    return await db.delete('alarms', where: 'id = ?', whereArgs: [id]);
  }
}
