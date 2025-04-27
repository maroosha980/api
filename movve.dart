import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'front.dart';

class StudentFormPage extends StatefulWidget {
  const StudentFormPage({super.key});

  @override
  StudentFormPageState createState() => StudentFormPageState();
}

class StudentFormPageState extends State<StudentFormPage> {
  Database? _db;

  final Map<String, TextEditingController> controllers = {
    "user_id": TextEditingController(),
    "course_name": TextEditingController(),
    "semester_no": TextEditingController(),
    "credit_hours": TextEditingController(),
    "marks": TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    initDb();
  }

  Future<void> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'students.db');

    await deleteDatabase(path);

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            course_name TEXT,
            semester_no TEXT,
            credit_hours TEXT,
            marks TEXT
          )
        ''');
      },
    );
    setState(() {});
  }

  Future<void> saveAndNavigate(BuildContext context) async {
    if (_db == null) return;

    await _db!.insert('students', {
      for (var entry in controllers.entries) entry.key: entry.value.text,
    });

    controllers.forEach((_, controller) => controller.clear());

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StudentDataPage(database: _db!)),
    );
  }

  @override
  void dispose() {
    controllers.forEach((_, controller) => controller.dispose());
    _db?.close();
    super.dispose();
  }

  String getLabel(String key) {
    switch (key) {
      case 'user_id':
        return 'User ID';
      case 'course_name':
        return 'Course Name';
      case 'semester_no':
        return 'Semester No';
      case 'credit_hours':
        return 'Credit Hours';
      case 'marks':
        return 'Marks';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('send to local storage'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: _db == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.yellow[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: controllers.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          labelText: getLabel(entry.key),
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => saveAndNavigate(context),
                icon: const Icon(Icons.save),
                label: const Text("ok!"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
