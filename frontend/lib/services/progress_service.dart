import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProgressService {
  static final String baseUrl = dotenv.env['BASE_URL']!;
  
  // Complete a task and update progress
  static Future<Map<String, dynamic>?> completeTask({
    required String studentUid,
    required int levelId,
    required int taskId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/student/$studentUid/complete-task'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'level_id': levelId,
          'task_id': taskId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to complete task: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error completing task: $e');
      return null;
    }
  }

  // Get student's current progress
  static Future<Map<String, dynamic>?> getProgress(String studentUid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/$studentUid/progress'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to get progress: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting progress: $e');
      return null;
    }
  }

  // Get available levels for student
  static Future<Map<String, dynamic>?> getAvailableLevels(String studentUid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/$studentUid/levels'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to get levels: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting levels: $e');
      return null;
    }
  }

  // Helper method to check if a level is unlocked
  static bool isLevelUnlocked(Map<String, dynamic> levels, int levelId) {
    if (levelId == 1) return true; // Level 1 always unlocked
    
    final previousLevel = levels[(levelId - 1).toString()];
    if (previousLevel == null) return false;
    
    final starsEarned = previousLevel['stars_earned'] as int? ?? 0;
    return starsEarned >= 2;
  }

  // Helper method to get total stars from progress data
  static int getTotalStars(Map<String, dynamic> progressData) {
    final progress = progressData['progress'] as Map<String, dynamic>? ?? {};
    return progress['total_stars'] as int? ?? 0;
  }

  // Helper method to get stars for specific level
  static int getLevelStars(Map<String, dynamic> progressData, int levelId) {
    final progress = progressData['progress'] as Map<String, dynamic>? ?? {};
    final levels = progress['levels'] as Map<String, dynamic>? ?? {};
    final levelData = levels[levelId.toString()];
    return levelData?['stars_earned'] as int? ?? 0;
  }
}