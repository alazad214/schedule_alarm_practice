import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PrayerDBHelper {
  static final PrayerDBHelper instance = PrayerDBHelper._init();
  static Database? _database;

  PrayerDBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('alarms.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alarms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city TEXT,
        date TEXT,
        prayer_name TEXT,
        is_enabled INTEGER
      )
    ''');
  }

  Future<void> insertOrUpdateAlarm(String city, String date, String prayerName, bool isEnabled) async {
    final db = await database;
    await db.insert(
      'alarms',
      {
        'city': city,
        'date': date,
        'prayer_name': prayerName,
        'is_enabled': isEnabled ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> getAlarmState(String city, String date, String prayerName) async {
    final db = await database;
    final result = await db.query(
      'alarms',
      where: 'city = ? AND date = ? AND prayer_name = ?',
      whereArgs: [city, date, prayerName],
    );
    return result.isNotEmpty && result.first['is_enabled'] == 1;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}