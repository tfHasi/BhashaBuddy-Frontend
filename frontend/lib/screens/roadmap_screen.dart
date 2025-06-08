import 'package:flutter/material.dart';

class RoadMapScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  RoadMapScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RoadMap')),
      body: Center(
        child: Text('RoadMap for ${user['type'] == 'student' ? 'Student' : 'Admin'}'),
      ),
    );
  }
}