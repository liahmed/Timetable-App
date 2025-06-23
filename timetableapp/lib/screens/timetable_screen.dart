import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Track/providers/course_provider.dart';
import 'dart:async';
import 'package:Track/screens/add_courses_screen.dart';

class TimetableScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? selectedCourses;

  const TimetableScreen({Key? key, this.selectedCourses}) : super(key: key);

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

    // Load courses from database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).fetchCourses();
    });

    // Setup timer to refresh every minute to update active classes
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  int _getCurrentDayIndex() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    return (currentWeekday >= 1 && currentWeekday <= 6)
        ? currentWeekday - 1
        : 6;
  }

  // Check if class is currently active
  bool _isClassActive(String startTime, String endTime) {
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return currentTime.compareTo(startTime) >= 0 &&
        currentTime.compareTo(endTime) <= 0;
  }

  Widget _buildTimeSlotGridItem(
    Map<String, dynamic> course,
    String currentDay,
  ) {
    final schedule = (course['schedule'] as List<dynamic>?)?.firstWhere(
      (s) => s['day'] == currentDay,
      orElse: () => null,
    );

    if (schedule == null) return SizedBox.shrink();

    final isActive =
        days[_getCurrentDayIndex()] == currentDay &&
        _isClassActive(schedule['startTime'], schedule['endTime']);

    // Extract details with null-safety
    final String courseCode = course['code'] as String? ?? '';
    final String roomNo = schedule['room'] as String? ?? '';
    final String degree = course['degree'] as String? ?? '';
    final String semester =
        (course['semester'] as String?)?.replaceAll('Semester ', '') ?? '';
    final String section = course['section'] as String? ?? '';
    final String startTime = schedule['startTime'] as String? ?? '';
    final String ampm = (schedule['ampm'] as String?)?.toUpperCase() ?? '';
    final String instructor = course['instructor'] as String? ?? '';

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
            // Room and Course Code
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  roomNo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.black : Colors.black87,
                  ),
                ),
                Text(
                  course['short_form'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.black : Colors.black87,
                  ),
                ),
              ],
            ),
            // Degree, Semester, Section
            Text(
              '$degree $semester$section',
              style: TextStyle(
                fontSize: 13,
                color: isActive ? Colors.black54 : Colors.black54,
              ),
            ),
            Spacer(),
            // Time
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  startTime,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    height: 0.9,
                    letterSpacing: -1,
                    color: isActive ? Colors.black : Colors.black87,
                  ),
                ),
                SizedBox(width: 4),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    ampm,
                    style: TextStyle(
                      fontSize: 14,
                      color: isActive ? Colors.black : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            // Teacher name
            Text(
              instructor,
              style: TextStyle(
                fontSize: 14,
                color: isActive ? Colors.black : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getCurrentCourses() {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    List<String> currentCourseIds = [];
    for (var course in courseProvider.courses) {
      final courseId = course['_id'] as String?;
      if (courseId != null) {
        currentCourseIds.add(courseId);
      }
    }
    return currentCourseIds;
  }

  void _navigateToAddCoursesScreen() {
    // Only pass selected courses if any were selected, otherwise pass an empty list
    final selectedCourses = widget.selectedCourses;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddCoursesScreen(
              selectedCourses:
                  (selectedCourses != null && selectedCourses.isNotEmpty)
                      ? selectedCourses.map((c) => c['_id'] as String).toList()
                      : <String>[],
            ),
      ),
    );
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
                    onPressed: _navigateToAddCoursesScreen,
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
              child: Consumer<CourseProvider>(
                builder: (context, courseProvider, child) {
                  if (courseProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (courseProvider.error.isNotEmpty) {
                    return Center(
                      child: Text('Error: ${courseProvider.error}'),
                    );
                  }

                  return PageView.builder(
                    controller: _pageController,
                    itemCount: days.length,
                    physics: RangeMaintainingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      List<Map<String, dynamic>> dayCourses;

                      if (widget.selectedCourses != null &&
                          widget.selectedCourses!.isNotEmpty) {
                        // Show only selected courses
                        dayCourses =
                            widget.selectedCourses!.where((course) {
                              return (course['schedule'] as List<dynamic>?)
                                      ?.any((s) => s['day'] == day) ??
                                  false;
                            }).toList();
                      } else {
                        // If no courses are selected, show all available courses
                        dayCourses =
                            courseProvider.courses.where((course) {
                              return (course['schedule'] as List<dynamic>?)
                                      ?.any((s) => s['day'] == day) ??
                                  false;
                            }).toList();
                      }

                      dayCourses.sort((a, b) {
                        final scheduleA = (a['schedule'] as List<dynamic>?)
                            ?.firstWhere(
                              (s) => s['day'] == day,
                              orElse: () => null,
                            );
                        final scheduleB = (b['schedule'] as List<dynamic>?)
                            ?.firstWhere(
                              (s) => s['day'] == day,
                              orElse: () => null,
                            );

                        if (scheduleA == null || scheduleB == null) return 0;

                        String startTimeA =
                            scheduleA['startTime'] as String? ?? '';
                        String startTimeB =
                            scheduleB['startTime'] as String? ?? '';

                        // Convert times to comparable format (HH:MM)
                        int timeToMinutes(String time) {
                          if (time.isEmpty) return 0;
                          final parts = time.split(':');
                          if (parts.length != 2) return 0;
                          return int.parse(parts[0]) * 60 + int.parse(parts[1]);
                        }

                        return timeToMinutes(
                          startTimeA,
                        ).compareTo(timeToMinutes(startTimeB));
                      });

                      return Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: dayCourses.length,
                          itemBuilder: (context, courseIndex) {
                            return _buildTimeSlotGridItem(
                              dayCourses[courseIndex],
                              day,
                            );
                          },
                        ),
                      );
                    },
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
