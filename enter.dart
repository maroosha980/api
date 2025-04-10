import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'api.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  AddStudentPageState createState() => AddStudentPageState();
}

class AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _fatherName = '';
  String _semester = '';
  String _shift = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.grey),
          color: Colors.blue[100],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter name' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Father Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter father name'
                    : null,
                onSaved: (value) => _fatherName = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Semester'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter semester'
                    : null,
                onSaved: (value) => _semester = value!,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Shift'),
                items: const [
                  DropdownMenuItem(value: 'Morning', child: Text('Morning')),
                  DropdownMenuItem(value: 'Evening', child: Text('Evening')),
                ],
                validator: (value) =>
                value == null ? 'Please select shift' : null,
                onChanged: (value) => _shift = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await GradeDatabaseHelper.instance.addStudent({
                      'name': _name,
                      'fatherName': _fatherName,
                      'semester': _semester,
                      'shift': _shift,
                    });

                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const GradeBookPage()),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
