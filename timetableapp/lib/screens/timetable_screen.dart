import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

import 'package:timetableapp/screens/add_courses_screen.dart';

class TimetableScreen extends StatefulWidget {
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  late PageController _pageController;
  double _currentPage = 0;
  Timer? _refreshTimer;
  DateTime _currentTime = DateTime.now();

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Weekend",
  ];

  Map<String, List<Map<String, String>>> timetableData = {};

  @override
  void initState() {
    super.initState();
    _currentPage = _getCurrentDayIndex().toDouble();
    _pageController = PageController(
      initialPage: _getCurrentDayIndex(),
      viewportFraction: 1.0,
    );

    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = _pageController.page ?? 0;
        });
      }
    });
    _loadTimetableData();

    // Setup timer to refresh every minute to update active classes
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  int _getCurrentDayIndex() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    return (currentWeekday >= 1 && currentWeekday <= 6)
        ? currentWeekday - 1
        : 6;
  }

  Future<void> _loadTimetableData() async {
    final prefs = await SharedPreferences.getInstance();
    final timetableJson = prefs.getString('timetableData');
    if (timetableJson != null) {
      try {
        final decodedData = json.decode(timetableJson);
        setState(() {
          timetableData = Map<String, List<Map<String, String>>>.from(
            decodedData.map(
              (key, value) => MapEntry(
                key,
                (value as List)
                    .map((item) => Map<String, String>.from(item as Map))
                    .toList(),
              ),
            ),
          );
        });
        print("Loaded timetable data: $timetableData"); // Debug print
      } catch (e) {
        print("Error parsing timetable data: $e");
        // Initialize with empty data on error
        timetableData = {for (var day in days) day: []};
      }
    } else {
      print("No timetable data found in SharedPreferences");
    }
  }

  // Check if class is currently active
  bool _isClassActive(String timeStr, String ampm) {
    final now = DateTime.now();

    // Parse class time
    final timeParts = timeStr.split(':');
    if (timeParts.length != 2) return false;

    int hours = int.tryParse(timeParts[0]) ?? 0;
    final minutes = int.tryParse(timeParts[1]) ?? 0;

    // Convert to 24-hour format
    if (ampm == 'PM' && hours < 12) {
      hours += 12;
    } else if (ampm == 'AM' && hours == 12) {
      hours = 0;
    }

    // Create class start and end DateTime (assuming 1-hour classes)
    final classStart = DateTime(now.year, now.month, now.day, hours, minutes);
    final classEnd = classStart.add(Duration(hours: 1));

    // Check if current time is within class time
    return now.isAfter(classStart) && now.isBefore(classEnd);
  }

  Widget _buildTimeSlot(Map<String, String> schedule, String day) {
    // Determine if class is active based on time
    final isActive = _isClassActive(
      schedule['time'] ?? '00:00',
      schedule['ampm'] ?? 'AM',
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isActive ? Color(0xFFC0EF7D) : Colors.white,
        border: Border.all(color: Color(0xFFC0EF7D), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      schedule['courseCode'] ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      schedule['roomNo'] ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              schedule['section'] ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  schedule['time'] ?? '',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    height: 0.9,
                  ),
                ),
                SizedBox(width: 2),
                Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    schedule['ampm'] ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              schedule['teacherName'] ?? '',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getDefaultTimeSlots() {
    return [
      {
        'courseCode': 'A4',
        'roomNo': 'DB',
        'section': 'BCS 5M',
        'time': '08:00',
        'ampm': 'AM',
        'teacherName': 'Basit Ali',
        'isActive': 'true',
      },
      {
        'courseCode': 'E1',
        'roomNo': 'GT',
        'section': 'BCS 5B',
        'time': '10:00',
        'ampm': 'AM',
        'teacherName': 'Dr Nazish Kanwal',
        'isActive': 'false',
      },
      {
        'courseCode': 'C18',
        'roomNo': 'LA',
        'section': 'BCS 3D',
        'time': '01:00',
        'ampm': 'PM',
        'teacherName': 'Muhammad Amjad',
        'isActive': 'false',
      },
      {
        'courseCode': 'E4',
        'roomNo': 'TBW',
        'section': 'BAI 5A',
        'time': '02:00',
        'ampm': 'PM',
        'teacherName': 'Javeria Ali',
        'isActive': 'false',
      },
      {
        'courseCode': 'CS Lab3',
        'roomNo': 'DB LAB',
        'section': 'BCS 5M',
        'time': '01:00',
        'ampm': 'PM',
        'teacherName': 'Mubashir',
        'isActive': 'false',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed height container for the header
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TRACK and Day text
                  Row(
                    children: [
                      Text(
                        "TRACK",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        days[_currentPage.round()],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  // Add button
                  IconButton(
                    icon: Icon(Icons.add, color: Color(0xFFC0EF7D), size: 28),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddCoursesScreen(
                                selectedCourses: _getCurrentCourses(),
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Custom Line Indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Row(
                children: List.generate(days.length, (index) {
                  bool isActive = index == _currentPage.round();
                  bool isBeforeActive = index < _currentPage.round();
                  double segmentWidth = (screenWidth * 0.88) / days.length;
                  return Container(
                    width: segmentWidth,
                    height: 3,
                    color:
                        isActive
                            ? Colors.black
                            : isBeforeActive
                            ? Colors.grey[400]
                            : Colors.grey[300],
                  );
                }),
              ),
            ),

            // Single PageView for both day text and timetable
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: days.length,
                physics: RangeMaintainingScrollPhysics(),
                itemBuilder: (context, index) {
                  final day = days[index];
                  final daySchedule = timetableData[day] ?? [];
                  final slotsToShow =
                      timetableData.isEmpty ||
                              (timetableData.values.every(
                                (list) => list.isEmpty,
                              ))
                          ? _getDefaultTimeSlots()
                          : daySchedule;

                  return Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: slotsToShow.length,
                      itemBuilder: (context, slotIndex) {
                        return _buildTimeSlotGridItem(
                          slotsToShow[slotIndex],
                          day,
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Copyright footer
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Limupani Studios ©",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                // textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method for grid item time slots
  Widget _buildTimeSlotGridItem(
    Map<String, String> schedule,
    String currentDay,
  ) {
    final isActive =
        days[_getCurrentDayIndex()] == currentDay &&
        _isClassActive(schedule['time'] ?? '00:00', schedule['ampm'] ?? 'AM');

    return Container(
      decoration: BoxDecoration(
        color: isActive ? Color(0xFFC0EF7D) : Colors.white,
        border: Border.all(color: Color(0xFFC0EF7D), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course code and room
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  schedule['courseCode'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  schedule['roomNo'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            // Section
            Text(
              schedule['section'] ?? '',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            Spacer(),
            // Time
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  schedule['time'] ?? '',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    height: 0.9,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(width: 4),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    schedule['ampm'] ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            // Teacher name
            Text(
              schedule['teacherName'] ?? '',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // Add this method to get currently displayed courses
  List<String> _getCurrentCourses() {
    List<String> currentCourses = [];
    for (var day in days) {
      if (timetableData[day] != null) {
        for (var course in timetableData[day]!) {
          String courseIdentifier =
              '${course['courseCode']}_${course['roomNo']}';
          currentCourses.add(courseIdentifier);
        }
      }
    }
    return currentCourses;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
}
