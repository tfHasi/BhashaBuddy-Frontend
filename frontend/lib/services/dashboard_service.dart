import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminService {
  static String baseUrl = dotenv.env['BASE_URL']!;
  // Get admin statistics
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading stats: $e');
    }
  }

  // Get all students
  static Future<Map<String, dynamic>> getStudents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/students'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading students: $e');
    }
  }

  // Delete a student
  static Future<bool> deleteStudent(String uid) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/students/$uid'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting student: $e');
    }
  }

  // Get all levels
  static Future<Map<String, dynamic>> getLevels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/levels'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load levels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading levels: $e');
    }
  }

  // Update a level
  static Future<bool> updateLevel(String levelId, List<String> tasks, List<String> translations) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/levels/$levelId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'tasks': tasks,
          'translations': translations,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating level: $e');
    }
  }
}