import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final String baseUrl = dotenv.env['BASE_URL']!;
  
  Future<Map<String, dynamic>?> studentSignup(String email, String password, String nickname) async {
    final response = await http.post(
      Uri.parse('$baseUrl/student/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'nickname': nickname,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail']);
    }
  }

  Future<Map<String, dynamic>?> adminSignup(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail']);
    }
  }

Future<Map<String, dynamic>?> login(String email, String password) async {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final userData = jsonDecode(response.body);
    return userData;
  } else {
    throw Exception(jsonDecode(response.body)['detail']);
  }
}

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}