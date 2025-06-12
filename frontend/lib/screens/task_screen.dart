import 'package:flutter/material.dart';

class TaskScreen extends StatelessWidget {
  final int level;
  final Map<String, dynamic> user;

  const TaskScreen({
    super.key,
    required this.level,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level $level Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text(
          'Tasks for Level $level will appear here.',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}