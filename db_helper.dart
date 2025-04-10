import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GradeDatabaseHelper {
  static final GradeDatabaseHelper instance = GradeDatabaseHelper._internal();
  static Database? _database;

  GradeDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'grades.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE grades (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            studentname TEXT,
            fathername TEXT,
            progname TEXT,
            shift TEXT,
            rollno TEXT,
            coursecode TEXT,
            coursetitle TEXT,
            credithours TEXT,
            obtainedmarks TEXT,
            mysemester TEXT,
            consider_status TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            fatherName TEXT,
            semester TEXT,
            shift TEXT
          );
        ''');
      },
    );
  }

  Future<void> insertGrades(List<Map<String, dynamic>> gradeList) async {
    final db = await database;
    await db.delete('grades');
    for (var grade in gradeList) {
      await db.insert('grades', grade);
    }
  }

  Future<List<Map<String, dynamic>>> getGrades() async {
    final db = await database;
    return await db.query('grades');
  }

  Future<void> deleteGrade(int id) async {
    final db = await database;
    await db.delete('grades', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> eraseAllGrades() async {
    final db = await database;
    await db.delete('grades');
  }

  Future<void> addStudent(Map<String, dynamic> student) async {
    final db = await database;
    await db.insert('students', student);
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    return await db.query('students');
  }
}
