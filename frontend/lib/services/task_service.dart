import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class TaskService {
  static final String baseUrl = dotenv.env['BASE_URL']!;

  // Fetch task words for a given level
  static Future<List<String>?> getTasksForLevel(int levelId) async {
    if (levelId < 1 || levelId > 6) {
      print('⚠️ Invalid level ID: $levelId');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/levels/$levelId/tasks'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return List<String>.from(body['tasks'] ?? []);
      } else {
        print('❌ Failed to fetch tasks: ${response.statusCode}');
        print(response.body);
        return null;
      }
    } catch (e) {
      print('❌ Error fetching tasks: $e');
      return null;
    }
  }

  // Fetch translations for a given level
  static Future<List<String>?> getTranslationsForLevel(int levelId) async {
    if (levelId < 1 || levelId > 6) {
      print('⚠️ Invalid level ID: $levelId');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/levels/$levelId/translations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return List<String>.from(body['translations'] ?? []);
      } else {
        print('❌ Failed to fetch translations: ${response.statusCode}');
        print(response.body);
        return null;
      }
    } catch (e) {
      print('❌ Error fetching translations: $e');
      return null;
    }
  }

  // Fetch complete level data (tasks + translations)
  static Future<Map<String, dynamic>?> getLevelData(int levelId) async {
    if (levelId < 1 || levelId > 6) {
      print('⚠️ Invalid level ID: $levelId');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/levels/$levelId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body;
      } else {
        print('❌ Failed to fetch level data: ${response.statusCode}');
        print(response.body);
        return null;
      }
    } catch (e) {
      print('❌ Error fetching level data: $e');
      return null;
    }
  }

  // Submit drawn characters for prediction
  static Future<Map<String, dynamic>?> predictTask({
    required String studentUid,
    required int levelId,
    required int taskId,
    required List<File> images,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/student/$studentUid/predict-task');
      final request = http.MultipartRequest('POST', uri);

      // Add form fields
      request.fields['level_id'] = levelId.toString();
      request.fields['task_id'] = taskId.toString();

      // Add image files
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final fileName = file.path.split('/').last;
        final mimeType = lookupMimeType(file.path) ?? 'image/png';
        final parts = mimeType.split('/');

        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            file.path,
            filename: fileName,
            contentType: MediaType(parts[0], parts[1]),
          ),
        );
      }

      // Send request and decode response
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ Prediction failed (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error predicting task: $e');
      return null;
    }
  }
}