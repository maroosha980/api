import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'db_helper.dart';
import 'enter.dart';

class GradeBookPage extends StatefulWidget {
  const GradeBookPage({super.key});

  @override
  GradeBookPageState createState() => GradeBookPageState();
}

class GradeBookPageState extends State<GradeBookPage> {
  List<Map<String, dynamic>> grades = [];
  List<Map<String, dynamic>> students = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGradesFromDb();
  }

  Future<void> fetchGrades() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://bgnuerp.online/api/gradeapi'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          final gradeList = List<Map<String, dynamic>>.from(data.map((item) => {
            'studentname': item['studentname'],
            'fathername': item['fathername'],
            'progname': item['progname'],
            'shift': item['shift'],
            'rollno': item['rollno'],
            'coursecode': item['coursecode'],
            'coursetitle': item['coursetitle'],
            'credithours': item['credithours'],
            'obtainedmarks': item['obtainedmarks'],
            'mysemester': item['mysemester'],
            'consider_status': item['consider_status'],
          }));
          await GradeDatabaseHelper.instance.insertGrades(gradeList);
          await _loadGradesFromDb();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data loaded and saved locally')),
            );
          }
        }
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _loadGradesFromDb() async {
    final gradeData = await GradeDatabaseHelper.instance.getGrades();
    final studentData = await GradeDatabaseHelper.instance.getStudents();
    setState(() {
      grades = gradeData;
      students = studentData;
    });
  }

  Future<void> deleteGrade(int index) async {
    final id = grades[index]['id'];
    await GradeDatabaseHelper.instance.deleteGrade(id);
    await _loadGradesFromDb();
  }

  Future<void> eraseData() async {
    await GradeDatabaseHelper.instance.eraseAllGrades();
    await _loadGradesFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Book'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: fetchGrades,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: eraseData,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddStudentPage()),
              );
              await _loadGradesFromDb();
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            if (grades.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Grades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: grades.length,
                itemBuilder: (context, index) {
                  final grade = grades[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Student: ${grade['studentname']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Father: ${grade['fathername']}'),
                          Text('Program: ${grade['progname']}'),
                          Text('Shift: ${grade['shift']}'),
                          Text('Roll No: ${grade['rollno']}'),
                          Text('Course Code: ${grade['coursecode']}'),
                          Text('Course Title: ${grade['coursetitle']}'),
                          Text('Credit Hours: ${grade['credithours']}'),
                          Text('Obtained Marks: ${grade['obtainedmarks']}'),
                          Text('Semester: ${grade['mysemester']}'),
                          Text('Status: ${grade['consider_status']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteGrade(index),
                      ),
                    ),
                  );
                },
              ),
            ],
            if (students.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Student: ${student['name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Father: ${student['fatherName']}'),
                          Text('Semester: ${student['semester']}'),
                          Text('Shift: ${student['shift']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
            if (grades.isEmpty && students.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No data available')),
              ),
          ],
        ),
      ),
    );
  }
}
