import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';

class EntryAndLoadScreen extends StatefulWidget {
  const EntryAndLoadScreen({super.key});

  @override
  State<EntryAndLoadScreen> createState() => _EntryAndLoadScreenState();
}

class _EntryAndLoadScreenState extends State<EntryAndLoadScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController marksController = TextEditingController();
  final TextEditingController semesternoController = TextEditingController();
  final TextEditingController creditHoursController = TextEditingController();
  final TextEditingController searchUserIdController = TextEditingController();

  List<Map<String, String>> courseList = [];
  Map<String, String>? selectedCourse;

  List<dynamic> userData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCourses(); // Fetch courses at start
  }

  // Fetch course list from fixed API
  Future<void> fetchCourses() async {
    final response = await http.get(Uri.parse('https://bgnuerp.online/api/get_courses?user_id=12122'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      setState(() {
        courseList = data.map<Map<String, String>>((item) {
          return {
            'code': item['subject_code'],
            'name': item['subject_name'],
          };
        }).toList();
      });
    }
  }

  // Submit data
  Future<void> submitData() async {
    if (selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course')),
      );
      return;
    }

    final uri = Uri.parse('https://devtechtop.com/management/public/api/grades');

    try {
      final response = await http.post(
        uri,
        body: {
          'user_id': userIdController.text.trim(),
          'course_name': selectedCourse!['name']!,
          'course_code': selectedCourse!['code'] ?? '',
          'marks': marksController.text.trim(),
          'semester_no': semesternoController.text.trim(),
          'credit_hours': creditHoursController.text.trim(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Data submitted successfully')),
        );
        _formKey.currentState?.reset();
        setState(() {
          selectedCourse = null;
        });
      } else {
        debugPrint('❌ Submission Error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to submit: ${response.body}')),
        );
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    }
  }

  // Fetch all user data
  Future<void> fetchData() async {
    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse('https://devtechtop.com/management/public/api/select_data'),
    );

    if (response.statusCode == 200) {
      try {
        final decoded = json.decode(response.body);
        final List<dynamic> data =
        decoded is List ? decoded : decoded['data'] ?? [];

        setState(() {
          userData = data;
          isLoading = false;
        });
      } catch (e) {
        debugPrint('Parsing error: $e');
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to parse data')),
        );
      }
    } else {
      debugPrint('Fetch error: ${response.body}');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch data')),
      );
    }
  }

  // Search by user ID
  Future<void> fetchDataByUserId() async {
    final userId = searchUserIdController.text.trim();
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter User ID to search')),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse('https://devtechtop.com/management/public/api/select_data'),
    );

    if (response.statusCode == 200) {
      try {
        final decoded = json.decode(response.body);
        final List<dynamic> data =
        decoded is List ? decoded : decoded['data'] ?? [];

        final filtered = data.where((item) => item['user_id'].toString() == userId).toList();

        setState(() {
          userData = filtered;
          isLoading = false;
        });

        if (filtered.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No records found for this User ID')),
          );
        }
      } catch (e) {
        debugPrint('Parsing error: $e');
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to parse data')),
        );
      }
    } else {
      debugPrint('Fetch error: ${response.body}');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entry of Data & Load')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: userIdController,
                    decoration: const InputDecoration(labelText: 'User ID'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter User ID' : null,
                  ),
                  DropdownSearch<Map<String, String>>(
                    items: courseList,
                    itemAsString: (item) => "${item['code']} - ${item['name']}",
                    selectedItem: selectedCourse,
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(labelText: 'Select Course'),
                    ),
                    onChanged: (value) {
                      setState(() => selectedCourse = value);
                    },
                  ),
                  TextFormField(
                    controller: marksController,
                    decoration: const InputDecoration(labelText: 'Marks'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter Marks' : null,
                  ),
                  TextFormField(
                    controller: semesternoController,
                    decoration: const InputDecoration(labelText: 'Semester No'),
                    validator: (value) => value!.isEmpty ? 'Enter Semester Number' : null,
                  ),
                  TextFormField(
                    controller: creditHoursController,
                    decoration: const InputDecoration(labelText: 'Credit Hours'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter Credit Hours' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            submitData();
                          }
                        },
                        child: const Text('Submit'),
                      ),
                      ElevatedButton(
                        onPressed: fetchData,
                        child: const Text('Load All'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : userData.isEmpty
                ? const Text('No data loaded')
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userData.length,
              itemBuilder: (context, index) {
                final item = userData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text('${item['course_name']}'),
                    subtitle: Text(
                      'User ID: ${item['user_id']}\n'
                          'Marks: ${item['marks']}\n'
                          'Semester No: ${item['semester_no']}\n'
                          'Credit Hours: ${item['credit_hours']}',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchUserIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Search by User ID',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: fetchDataByUserId,
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
