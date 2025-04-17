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
import 'package:timetableapp/screens/custom_selection_bar.dart';
import 'package:timetableapp/screens/timetable_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  List<Map<String, dynamic>> allCourses = [
    {
      "degree": "BCS",
      "semester": "Semester 5",
      "section": "M",
      "courseCode": "A4",
      "roomNo": "DB",
      "name": "PDC BCS 5M",
      "time": "08:00",
      "ampm": "AM",
      "teacher": "Basit Ali",
      "day": "Wednesday",
      "selected": false,
    },
    {
      "degree": "BCS",
      "semester": "Semester 5",
      "section": "B",
      "courseCode": "E1",
      "roomNo": "GT",
      "name": "GT BCS 5B",
      "time": "10:00",
      "ampm": "AM",
      "teacher": "Dr Nazish Kanwal",
      "day": "Wednesday",
      "selected": false,
    },
    {
      "degree": "BCS",
      "semester": "Semester 3",
      "section": "D",
      "courseCode": "C18",
      "roomNo": "LA",
      "name": "LA BCS 3D",
      "time": "01:00",
      "ampm": "PM",
      "teacher": "Muhammad Amjad",
      "day": "Wednesday",
      "selected": false,
    },
    {
      "degree": "BAI",
      "semester": "Semester 5",
      "section": "A",
      "courseCode": "E4",
      "roomNo": "TBW",
      "name": "AI BAI 5A",
      "time": "02:00",
      "ampm": "PM",
      "teacher": "Javeria Ali",
      "day": "Wednesday",
      "selected": false,
    },
    {
      "degree": "BCS",
      "semester": "Semester 5",
      "section": "M",
      "courseCode": "CS Lab3",
      "roomNo": "DB LAB",
      "name": "DB LAB BCS 5M",
      "time": "01:00",
      "ampm": "PM",
      "teacher": "Mubashir",
      "day": "Wednesday",
      "selected": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedCourses != null) {
      // Mark courses as selected if they were in the timetable
      for (var course in allCourses) {
        String courseIdentifier = '${course["courseCode"]}_${course["roomNo"]}';
        if (widget.selectedCourses!.contains(courseIdentifier)) {
          course["selected"] = true;
        }
      }
    }
  }

  // Load existing timetable data when initializing
  Future<void> _loadExistingTimetableData() async {
    final prefs = await SharedPreferences.getInstance();
    final timetableJson = prefs.getString('timetableData');
    if (timetableJson != null) {
      final decodedData = json.decode(timetableJson);
      Map<String, List<Map<String, dynamic>>> existingData =
          Map<String, List<Map<String, dynamic>>>.from(
            decodedData.map(
              (key, value) => MapEntry(
                key,
                (value as List)
                    .map((item) => Map<String, dynamic>.from(item as Map))
                    .toList(),
              ),
            ),
          );

      // Mark courses as selected based on existing timetable
      for (var daySchedule in existingData.values) {
        for (var scheduledCourse in daySchedule) {
          for (var course in allCourses) {
            if (course["courseCode"] == scheduledCourse["courseCode"] &&
                course["roomNo"] == scheduledCourse["roomNo"]) {
              setState(() {
                course["selected"] = true;
              });
            }
          }
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadExistingTimetableData();
  }

  List<Map<String, dynamic>> getFilteredCourses() {
    return allCourses.where((course) {
      return (selectedDegree.isEmpty || course["degree"] == selectedDegree) &&
          (selectedSemester.isEmpty ||
              course["semester"] == selectedSemester) &&
          (selectedSection.isEmpty || course["section"] == selectedSection);
    }).toList();
  }

  void onSelectionChanged({String? degree, String? semester, String? section}) {
    setState(() {
      if (degree != null) {
        selectedDegree = degree;
        selectedSemester = "";
        selectedSection = "";
      } else if (semester != null) {
        selectedSemester = semester;
        selectedSection = "";
      } else if (section != null) {
        selectedSection = section;
      }
    });
  }

  Future<void> _saveTimetableData() async {
    final selectedCourses =
        allCourses.where((course) => course["selected"]).toList();

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
      final day = course["day"] as String;
      timetableData[day]!.add({
        'courseCode': course["courseCode"] ?? '',
        'roomNo': course["roomNo"] ?? '',
        'section': course["degree"] + " " + course["section"],
        'time': course["time"] ?? '',
        'ampm': course["ampm"] ?? '',
        'teacherName': course["teacher"] ?? '',
        'isActive': 'false', // Will be determined by time in TimetableScreen
      });
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

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('timetableData', json.encode(timetableData));

    // Navigate to TimetableScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TimetableScreen()),
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
              child: ListView.builder(
                itemCount: getFilteredCourses().length,
                itemBuilder: (context, index) {
                  var course = getFilteredCourses()[index];
                  return ListTile(
                    leading: Checkbox(
                      value: course["selected"],
                      onChanged: (bool? value) {
                        setState(() {
                          course["selected"] = value!;
                        });
                      },
                      activeColor: Color(0XFFC0EF7D),
                      checkColor: Color(0xFF1F1D1E),
                    ),
                    title: Text(
                      course["name"],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(course["teacher"]),
                    tileColor:
                        course["selected"]
                            ? Colors.transparent
                            : Colors.transparent,
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
