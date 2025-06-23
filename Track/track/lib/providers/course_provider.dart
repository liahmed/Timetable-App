import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';

class Course {
  final String id;
  final String name;
  final String instructor;
  final String schedule;

  Course({
    required this.id,
    required this.name,
    required this.instructor,
    required this.schedule,
  });
}

class CourseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Course> _courses = [];
  bool _isLoading = false;
  String _error = '';

  List<Course> get courses => [..._courses];
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _courses.clear();
      final apiCourses = await _apiService.getCourses();
      for (var course in apiCourses) {
        _courses.add(
          Course(
            id: course['_id'],
            name: course['name'],
            instructor: course['instructor'],
            schedule: course['schedule'],
          ),
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCourse(Course course) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final courseData = {
        'name': course.name,
        'instructor': course.instructor,
        'schedule': course.schedule,
      };
      final newCourse = await _apiService.addCourse(courseData);
      _courses.add(
        Course(
          id: newCourse['_id'],
          name: newCourse['name'],
          instructor: newCourse['instructor'],
          schedule: newCourse['schedule'],
        ),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCourse(
    String courseId,
    Map<String, dynamic> courseData,
  ) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final updatedCourse = await _apiService.updateCourse(
        courseId,
        courseData,
      );
      final index = _courses.indexWhere((course) => course.id == courseId);
      if (index != -1) {
        _courses[index] = Course(
          id: updatedCourse['_id'],
          name: updatedCourse['name'],
          instructor: updatedCourse['instructor'],
          schedule: updatedCourse['schedule'],
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCourse(String courseId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _apiService.deleteCourse(courseId);
      _courses.removeWhere((course) => course.id == courseId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeCourse(String id) {
    _courses.removeWhere((course) => course.id == id);
    notifyListeners();
  }
}
