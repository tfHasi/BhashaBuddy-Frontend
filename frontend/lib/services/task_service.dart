import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TaskService {
  static final String baseUrl = dotenv.env['BASE_URL']!;

  static Future<List<dynamic>?> getTasksForLevel(int levelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/levels/$levelId/tasks'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['tasks'] ?? [];
      } else if (response.statusCode == 404) {
        print('Level $levelId not found');
        return null;
      } else if (response.statusCode == 400) {
        print('Invalid level ID: $levelId');
        return null;
      } else {
        print('Failed to get tasks: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching tasks for level $levelId: $e');
      return null;
    }
  }

  // Helper method to validate level ID before making request
  static bool isValidLevelId(int levelId) {
    return levelId >= 1 && levelId <= 6; 
  }

  // Enhanced method with validation
  static Future<List<dynamic>?> getTasksForLevelSafe(int levelId) async {
    if (!isValidLevelId(levelId)) {
      print('Invalid level ID: $levelId');
      return null;
    }
    return await getTasksForLevel(levelId);
  }
}