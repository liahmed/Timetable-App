import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:27012/api';
  static const String tokenKey = 'auth_token';

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Store token
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Remove token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await setToken(data['token']);
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await setToken(data['token']);
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Get all courses
  Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/courses'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load courses');
    }
  }

  // Add a new course
  Future<Map<String, dynamic>> addCourse(Map<String, dynamic> course) async {
    final response = await http.post(
      Uri.parse('$baseUrl/courses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(course),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add course');
    }
  }

  // Update a course
  Future<Map<String, dynamic>> updateCourse(
    String id,
    Map<String, dynamic> course,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/courses/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(course),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update course');
    }
  }

  // Delete a course
  Future<void> deleteCourse(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/courses/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete course');
    }
  }

  // Timetable endpoints
  static Future<List<dynamic>> getUserTimetable(String userId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/timetable/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  static Future<void> addCourseToTimetable(
    String userId,
    String courseId,
  ) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/timetable/$userId/courses/$courseId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  static Future<void> removeCourseFromTimetable(
    String userId,
    String courseId,
  ) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/timetable/$userId/courses/$courseId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}
