import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/task_service.dart';
import './widgets/canvas_widget.dart';

class TaskScreen extends StatefulWidget {
  final int level;
  final Map<String, dynamic> user;

  const TaskScreen({super.key, required this.level, required this.user});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<String>? tasks;
  int currentTaskIndex = 0;
  Map<int, List<Uint8List?>> capturedImages = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loaded = await TaskService.getTasksForLevel(widget.level);
    if (mounted) setState(() => tasks = loaded);
  }

  void _nextTask() {
    if (currentTaskIndex < (tasks?.length ?? 0) - 1) {
      setState(() => currentTaskIndex++);
    }
  }

  void _previousTask() {
    if (currentTaskIndex > 0) {
      setState(() => currentTaskIndex--);
    }
  }

  Future<void> _submitTask() async {
    final word = tasks?[currentTaskIndex] ?? '';
    final images = capturedImages[currentTaskIndex] ?? [];

    if (images.length != word.length || images.any((img) => img == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw all characters')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing your drawings...'),
          ],
        ),
      ),
    );

    try {
      final dir = await getTemporaryDirectory();
      final files = await Future.wait(
        images.asMap().entries.map((e) async {
          final file = File('${dir.path}/char_${e.key}.png');
          await file.writeAsBytes(e.value!);
          return file;
        }),
      );

      final result = await TaskService.predictTask(
        studentUid: widget.user['uid'],
        levelId: widget.level,
        taskId: currentTaskIndex,
        images: files,
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (result != null) {
        _showResultDialog(
          correct: result['correct'] == true,
          predicted: result['predicted_word'],
          expected: result['target_word'],
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showResultDialog({
    required bool correct,
    required String predicted,
    required String expected,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? "Correct!" : "Try Again"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Your answer: $predicted"),
            Text("Expected: $expected"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(correct ? 'Continue' : 'Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tasks == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final word = tasks![currentTaskIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Level ${widget.level}')),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentTaskIndex + 1) / tasks!.length,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(word.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    children: List.generate(word.length, (i) => Column(
                      children: [
                        Text(word[i].toUpperCase()),
                        const SizedBox(height: 8),
                        DrawableCanvas(
                          size: 100,
                          onCapture: (bytes) {
                            capturedImages[currentTaskIndex] ??= 
                              List.filled(word.length, null);
                            capturedImages[currentTaskIndex]![i] = bytes;
                          },
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousTask,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: _submitTask,
                  child: const Text('Submit'),
                ),
                ElevatedButton(
                  onPressed: _nextTask,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}