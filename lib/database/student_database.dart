import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class StudentDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    final databasesPath = await getDatabasesPath();
    await Directory(databasesPath).create(recursive: true);
    final dbPath = join(databasesPath, 'students.db');

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            admission TEXT,
            course TEXT
          )
        ''');
      },
    );

    return _database!;
  }

  static Future<List<Map<String, dynamic>>> getAllStudents() async {
    final db = await database;
    return await db.query('students', orderBy: 'name COLLATE NOCASE');
  }

  static Future<int> insertStudent(Map<String, String> student) async {
    final db = await database;
    return await db.insert('students', {
      'name': student['name'],
      'admission': student['adm'],
      'course': student['course'],
    });
  }

  static Future<int> updateStudent(int id, Map<String, String> student) async {
    final db = await database;
    return await db.update('students', {
      'name': student['name'],
      'admission': student['adm'],
      'course': student['course'],
    }, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  static Future<String> exportCsv() async {
    final rows = await getAllStudents();
    final header = 'id,name,admission,course';
    final lines = [header];
    for (var r in rows) {
      final line = '${r['id']},"${r['name']}","${r['admission']}","${r['course']}"';
      lines.add(line);
    }

    final csv = lines.join('\n');

    final dir = await getApplicationDocumentsDirectory();
    final file = File(join(dir.path, 'students_export_${DateTime.now().millisecondsSinceEpoch}.csv'));
    await file.writeAsString(csv);
    return file.path;
  }

  static Future<int> importCsv(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return 0;
    final content = await file.readAsString();
    final lines = content.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return 0;
    // skip header if present
    var start = 0;
    if (lines[0].toLowerCase().contains('name') && lines[0].toLowerCase().contains('admission')) start = 1;

    int inserted = 0;
    for (var i = start; i < lines.length; i++) {
      final cols = _parseCsvLine(lines[i]);
      if (cols.length >= 4) {
        final name = cols[1];
        final admission = cols[2];
        final course = cols[3];
        await insertStudent({'name': name, 'adm': admission, 'course': course});
        inserted++;
      }
    }
    return inserted;
  }

  static List<String> _parseCsvLine(String line) {
    final chars = line.split('');
    final fields = <String>[];
    var buffer = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < chars.length; i++) {
      final c = chars[i];
      if (c == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (c == ',' && !inQuotes) {
        fields.add(buffer.toString());
        buffer = StringBuffer();
        continue;
      }
      buffer.write(c);
    }
    fields.add(buffer.toString());
    return fields;
  }
}