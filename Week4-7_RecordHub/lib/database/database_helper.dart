import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/record.dart';
import '../models/attendance_record.dart';

class DatabaseHelper {
  static const _databaseName = 'recordhub.db';
  static const _databaseVersion = 2;
  static const table = 'records';
  static const attendanceTable = 'attendance_records';

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        course TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $attendanceTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        record_id INTEGER NOT NULL,
        student_name TEXT NOT NULL,
        course TEXT NOT NULL,
        attendance_date TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(record_id, attendance_date)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $attendanceTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          record_id INTEGER NOT NULL,
          student_name TEXT NOT NULL,
          course TEXT NOT NULL,
          attendance_date TEXT NOT NULL,
          status TEXT NOT NULL,
          created_at TEXT NOT NULL,
          UNIQUE(record_id, attendance_date)
        )
      ''');
    }
  }

  Future<int> insertRecord(Record record) async {
    final db = await database;
    return await db.insert(table, record.toMap());
  }

  Future<List<Record>> getRecords() async {
    final db = await database;
    final maps = await db.query(table);
    return List.generate(maps.length, (i) => Record.fromMap(maps[i]));
  }

  Future<int> updateRecord(Record record) async {
    final db = await database;
    return await db.update(
      table,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    await db.delete(
      attendanceTable,
      where: 'record_id = ?',
      whereArgs: [id],
    );
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> saveAttendance(AttendanceRecord attendanceRecord) async {
    final db = await database;
    return await db.insert(
      attendanceTable,
      attendanceRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AttendanceRecord>> getAttendanceRecords({
    String? startDate,
    String? endDate,
  }) async {
    final db = await database;
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (startDate != null) {
      whereClauses.add('attendance_date >= ?');
      whereArgs.add(startDate);
    }

    if (endDate != null) {
      whereClauses.add('attendance_date <= ?');
      whereArgs.add(endDate);
    }

    final maps = await db.query(
      attendanceTable,
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'attendance_date DESC, student_name ASC',
    );

    return List.generate(
      maps.length,
      (i) => AttendanceRecord.fromMap(maps[i]),
    );
  }

  Future<void> deleteAttendanceByRecordId(int recordId) async {
    final db = await database;
    await db.delete(
      attendanceTable,
      where: 'record_id = ?',
      whereArgs: [recordId],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
