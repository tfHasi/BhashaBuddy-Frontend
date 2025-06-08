import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  CreditsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Credits')),
      body: Center(
        child: Text('Credits for ${user['type'] == 'student' ? 'Student' : 'Admin'}'),
      ),
    );
  }
}