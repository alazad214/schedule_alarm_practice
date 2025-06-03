import 'dart:developer';
import 'package:sqflite/sqflite.dart';

class PrayerDBHelper {
  static final PrayerDBHelper instance = PrayerDBHelper._init();
  static Database? _database;

  PrayerDBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('prayer_alarm.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$filePath';

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alarm_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city TEXT NOT NULL,
        date TEXT NOT NULL,
        prayer_name TEXT NOT NULL,
        is_enabled INTEGER NOT NULL,
        UNIQUE(city, date, prayer_name) ON CONFLICT REPLACE
      )
    ''');
    log('DB: alarm_table created with UNIQUE constraint');
  }

  Future<void> insertOrUpdateAlarm(
    String city,
    String date,
    String prayerName,
    bool isEnabled,
  ) async {
    final db = await instance.database;
    await db.insert('alarm_table', {
      'city': city,
      'date': date,
      'prayer_name': prayerName,
      'is_enabled': isEnabled ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    log('DB: Saved $city | $date | $prayerName => $isEnabled');
  }

  Future<bool> getAlarmState(
    String city,
    String date,
    String prayerName,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'alarm_table',
      where: 'city = ? AND date = ? AND prayer_name = ?',
      whereArgs: [city, date, prayerName],
    );

    if (result.isNotEmpty) {
      final row = result.first;
      final intVal = row['is_enabled'] as int? ?? 0;
      final boolVal = intVal == 1;
      log('DB: Read $city | $date | $prayerName => $boolVal');
      return boolVal;
    } else {
      log('DB: No record found for $city | $date | $prayerName');
      return false;
    }
  }
}
