import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch courses when the screen is first loaded
    Future.microtask(
      () => Provider.of<CourseProvider>(context, listen: false).fetchCourses(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          if (courseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (courseProvider.error.isNotEmpty) {
            return Center(child: Text(courseProvider.error));
          }

          final courses = courseProvider.courses;
          if (courses.isEmpty) {
            return const Center(child: Text('No courses available'));
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(course.name),
                  subtitle: Text('${course.instructor}\n${course.schedule}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => courseProvider.deleteCourse(course.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_courses'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
