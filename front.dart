import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class StudentDataPage extends StatefulWidget {
  final Database database;

  const StudentDataPage({super.key, required this.database});

  @override
  State<StudentDataPage> createState() => _StudentDataPageState();
}

class _StudentDataPageState extends State<StudentDataPage> {
  List<Map<String, dynamic>> studentList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final data = await widget.database.query('students');
    setState(() {
      studentList = data;
    });
  }

  Future<void> sendToApi() async {
    const String apiUrl = "https://devtechtop.com/management/public/api/grades";
    bool allSuccess = true;

    setState(() {
      isLoading = true;
    });

    for (var student in studentList) {
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "user_id": student["user_id"],
            "course_name": student["course_name"],
            "semester_no": student["semester_no"],
            "credit_hours": student["credit_hours"],
            "marks": student["marks"],
          }),
        );

        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (response.statusCode != 200) {
          allSuccess = false;
          print("❌ Failed to send: ${student["user_id"]}");
        }
      } catch (e) {
        allSuccess = false;
        print("❌ Error sending data: $e");
      }
    }

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(BuildContext as BuildContext).showSnackBar(
      SnackBar(
        content: Text(allSuccess ? '✅ All data sent successfully!' : '⚠️ Some data failed to send.'),
        backgroundColor: allSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Students'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: studentList.isEmpty
                  ? const Center(child: Text('No data found.'))
                  : ListView.builder(
                itemCount: studentList.length,
                itemBuilder: (context, index) {
                  final student = studentList[index];
                  return Card(
                    color: Colors.yellow[100],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("User ID: ${student['user_id']}"),
                          Text("Course Name: ${student['course_name']}"),
                          Text("Semester No: ${student['semester_no']}"),
                          Text("Credit Hours: ${student['credit_hours']}"),
                          Text("Marks: ${student['marks']}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : sendToApi,
              icon: isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              )
                  : const Icon(Icons.cloud_upload),
              label: Text(isLoading ? 'Uploading...' : 'Upload to Server'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
