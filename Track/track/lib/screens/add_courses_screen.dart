// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:timetableapp/screens/custom_selection_bar.dart';

// // class AddCoursesScreen extends StatefulWidget {
// //   @override
// //   _AddCoursesScreenState createState() => _AddCoursesScreenState();
// // }

// // class _AddCoursesScreenState extends State<AddCoursesScreen> {
// //   List<Map<String, dynamic>> courses = [];
// //   bool isLoading = true; // Show loading until data is fetched

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchCourses(); // Fetch courses from backend
// //   }

// //   Future<void> fetchCourses() async {
// //     final url = Uri.parse(
// //       'https://your-api-url.com/api/courses',
// //     ); // Replace with actual API
// //     try {
// //       final response = await http.get(url);
// //       if (response.statusCode == 200) {
// //         final List<dynamic> data = json.decode(response.body);
// //         setState(() {
// //           courses =
// //               data
// //                   .map(
// //                     (course) => {
// //                       "id": course["_id"],
// //                       "name": course["course_name"],
// //                       "teacher": course["teacher_name"],
// //                       "selected": false, // Initially unselected
// //                     },
// //                   )
// //                   .toList();
// //           isLoading = false;
// //         });
// //       } else {
// //         throw Exception('Failed to load courses');
// //       }
// //     } catch (error) {
// //       print('Error fetching courses: $error');
// //       setState(() {
// //         isLoading = false;
// //       });
// //     }
// //   }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';

class AddCoursesScreen extends StatefulWidget {
  const AddCoursesScreen({super.key});

  @override
  State<AddCoursesScreen> createState() => _AddCoursesScreenState();
}

class _AddCoursesScreenState extends State<AddCoursesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructorController = TextEditingController();
  final _scheduleController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _instructorController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final course = Course(
        id: DateTime.now().toString(),
        name: _nameController.text,
        instructor: _instructorController.text,
        schedule: _scheduleController.text,
      );
      Provider.of<CourseProvider>(context, listen: false).addCourse(course);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _instructorController,
                decoration: const InputDecoration(labelText: 'Instructor'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an instructor name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _scheduleController,
                decoration: const InputDecoration(labelText: 'Schedule'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a schedule';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
