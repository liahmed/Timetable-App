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
import 'package:Track/screens/custom_selection_bar.dart';
import 'package:Track/screens/timetable_screen.dart';
import 'package:Track/providers/course_provider.dart';

class AddCoursesScreen extends StatefulWidget {
  final List<String>? selectedCourses;

  const AddCoursesScreen({super.key, this.selectedCourses});

  @override
  _AddCoursesScreenState createState() => _AddCoursesScreenState();
}

class _AddCoursesScreenState extends State<AddCoursesScreen> {
  String selectedDegree = "";
  String selectedSemester = "";
  String selectedSection = "";
  Set<String> selectedCourseIds = {};

  @override
  void initState() {
    super.initState();
    // Only initialize selected courses if the list is not null AND not empty
    if (widget.selectedCourses != null && widget.selectedCourses!.isNotEmpty) {
      selectedCourseIds.addAll(widget.selectedCourses!);
    }
    // Fetch courses when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).fetchCourses();
    });
  }

  List<Map<String, dynamic>> getFilteredCourses() {
    final courseProvider = Provider.of<CourseProvider>(context);
    if (courseProvider.courses.isEmpty) return [];

    return courseProvider.courses.where((course) {
      final courseDegree =
          course["degree"] as String? ?? ''; // Handle null with empty string
      final courseSemester =
          course["semester"] as String? ?? ''; // Handle null with empty string
      final courseSection =
          course["section"] as String? ?? ''; // Handle null with empty string

      // If no filters are selected, show all courses
      if (selectedDegree.isEmpty &&
          selectedSemester.isEmpty &&
          selectedSection.isEmpty) {
        return true;
      }

      // If only degree is selected, show all courses of that degree
      if (selectedDegree.isNotEmpty &&
          selectedSemester.isEmpty &&
          selectedSection.isEmpty) {
        return courseDegree == selectedDegree;
      }

      // If degree and semester are selected, show courses matching both
      if (selectedDegree.isNotEmpty &&
          selectedSemester.isNotEmpty &&
          selectedSection.isEmpty) {
        return courseDegree == selectedDegree &&
            courseSemester == selectedSemester;
      }

      // If all filters are selected, show only courses matching all criteria
      if (selectedDegree.isNotEmpty &&
          selectedSemester.isNotEmpty &&
          selectedSection.isNotEmpty) {
        return courseDegree == selectedDegree &&
            courseSemester == selectedSemester &&
            courseSection == selectedSection;
      }

      return false;
    }).toList();
  }

  void onSelectionChanged({String? degree, String? semester, String? section}) {
    setState(() {
      if (degree != null) {
        selectedDegree = degree; // Assign directly if not null
        selectedSemester = ""; // Reset dependent filters
        selectedSection = "";
      } else if (semester != null) {
        selectedSemester = semester; // Assign directly if not null
        selectedSection = ""; // Reset dependent filters
      } else if (section != null) {
        selectedSection = section; // Assign directly if not null
      }
    });
  }

  void toggleCourseSelection(String courseId, bool selected) {
    setState(() {
      if (selected) {
        selectedCourseIds.add(courseId);
      } else {
        selectedCourseIds.remove(courseId);
      }
    });
  }

  Future<void> _saveTimetableData() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final selectedCourses =
        courseProvider.courses.where((course) {
          final courseId = course["_id"] as String?;
          return courseId != null && selectedCourseIds.contains(courseId);
        }).toList();

    // Create a timetable data structure organized by days
    Map<String, List<Map<String, String>>> timetableData = {};

    // Initialize all days with empty lists
    for (String day in [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Weekend",
    ]) {
      timetableData[day] = [];
    }

    // Add selected courses to their designated days
    for (var course in selectedCourses) {
      final schedule = course['schedule'] as List<dynamic>?;
      if (schedule == null) continue;

      for (var scheduleItem in schedule) {
        final day = scheduleItem['day'] as String?;
        if (day == null) continue;

        timetableData[day]!.add({
          'courseCode': course['code'] as String? ?? '',
          'roomNo': scheduleItem['room'] as String? ?? '',
          'section': course['short_form'] as String? ?? '',
          'time': scheduleItem['startTime'] as String? ?? '',
          'ampm':
              (scheduleItem['startTime'] as String?)?.contains('PM') == true
                  ? 'PM'
                  : 'AM',
          'teacherName': course['instructor'] as String? ?? '',
          'isActive': 'false',
        });
      }
    }

    // Sort courses by time for each day
    for (var day in timetableData.keys) {
      timetableData[day]!.sort((a, b) {
        // Convert times to comparable format
        int timeToMinutes(String time, String ampm) {
          final parts = time.split(':');
          int hours = int.parse(parts[0]);
          int minutes = int.parse(parts[1]);
          if (ampm == 'PM' && hours < 12) hours += 12;
          if (ampm == 'AM' && hours == 12) hours = 0;
          return hours * 60 + minutes;
        }

        final timeA = timeToMinutes(a['time']!, a['ampm']!);
        final timeB = timeToMinutes(b['time']!, b['ampm']!);
        return timeA.compareTo(timeB);
      });
    }

    // Navigate to TimetableScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TimetableScreen(selectedCourses: selectedCourses),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CourseSelectionBar(
              onDegreeSelected: (degree) => onSelectionChanged(degree: degree),
              onSemesterSelected:
                  (semester) => onSelectionChanged(semester: semester),
              onSectionSelected:
                  (section) => onSelectionChanged(section: section),
              onSave: _saveTimetableData,
            ),
            Expanded(
              child: Consumer<CourseProvider>(
                builder: (context, courseProvider, child) {
                  if (courseProvider?.isLoading ?? false) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (courseProvider?.error != null) {
                    return Center(child: Text(courseProvider!.error));
                  }

                  final courses = getFilteredCourses();
                  if (courses.isEmpty) {
                    return Center(child: Text('No courses available'));
                  }

                  return ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      var course = courses[index];
                      final courseId = course["_id"] as String?;
                      if (courseId == null) return SizedBox.shrink();

                      final isSelected = selectedCourseIds.contains(courseId);

                      return ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            if (value != null) {
                              toggleCourseSelection(courseId, value);
                            }
                          },
                          activeColor: Color(0XFFC0EF7D),
                          checkColor: Color(0xFF1F1D1E),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // Short form + degree/semester/section
                              '${course["short_form"] as String? ?? ""} '
                              '${course["degree"] as String? ?? ""} '
                              '${(course["semester"] as String?)?.replaceAll("Semester ", "") ?? ""}'
                              '${course["section"] as String? ?? ""}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              course["instructor"] as String? ??
                                  'Unknown Instructor',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        tileColor:
                            isSelected
                                ? Color(0XFFC0EF7D).withOpacity(0.1)
                                : Colors.transparent,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
