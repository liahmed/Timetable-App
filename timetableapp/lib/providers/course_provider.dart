import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class CourseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = false;
  String _error = '';

  List<Map<String, dynamic>> get courses => _courses;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _courses = await _apiService.getCourses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCourse(Map<String, dynamic> courseData) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newCourse = await _apiService.addCourse(courseData);
      _courses.add(newCourse);
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
      final index = _courses.indexWhere((course) => course['_id'] == courseId);
      if (index != -1) {
        _courses[index] = updatedCourse;
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
      _courses.removeWhere((course) => course['_id'] == courseId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
