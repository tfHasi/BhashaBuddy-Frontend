import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final AuthService _authService = AuthService();

  HomeScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            if (user['type'] == 'student') ...[
              Text('Student ID: ${user['sid']}'),
              Text('Nickname: ${user['nickname']}'),
            ] else ...[
              Text('Admin ID: ${user['aid']}'),
            ],
            SizedBox(height: 24),
            Text('User Type: ${user['type'].toUpperCase()}'),
          ],
        ),
      ),
    );
  }
}