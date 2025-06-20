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
  Map<int, List<Uint8List>> capturedImages = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loaded = await TaskService.getTasksForLevel(widget.level);
    if (loaded != null) setState(() => tasks = loaded);
  }

  Future<void> _submitTask(int taskIndex) async {
    final images = capturedImages[taskIndex];
    if (images == null || images.length != tasks![taskIndex].length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all boxes')),
      );
      return;
    }

    // Save images temporarily
    final dir = await getTemporaryDirectory();
    List<File> files = [];
    for (int i = 0; i < images.length; i++) {
      final file = File('${dir.path}/char_$i.png');
      await file.writeAsBytes(images[i]);
      files.add(file);
    }

    final result = await TaskService.predictTask(
      studentUid: widget.user['uid'],
      levelId: widget.level,
      taskId: taskIndex,
      images: files,
    );

    if (result != null) {
      final correct = result['correct'] == true;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(correct ? "✅ Correct!" : "❌ Try Again"),
          content: Text(
              "Predicted: ${result['predicted_word']}\nExpected: ${result['target_word']}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Level ${widget.level} Tasks')),
      body: tasks == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tasks!.length,
              itemBuilder: (context, taskIndex) {
                final word = tasks![taskIndex];
                final charCount = word.length;

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Task ${taskIndex + 1}: $word'),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(charCount, (charIndex) {
                            return Padding(
                              padding: const EdgeInsets.all(4),
                              child: DrawableCanvas(
                                onCapture: (bytes) {
                                  capturedImages[taskIndex] ??= List.filled(charCount, Uint8List(0));
                                  capturedImages[taskIndex]![charIndex] = bytes;
                                },
                              ),
                            );
                          }),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => _submitTask(taskIndex),
                            child: const Text('Submit'),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}