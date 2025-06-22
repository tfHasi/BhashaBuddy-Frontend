import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/task_service.dart';
import './widgets/canvas_widget.dart';
import './widgets/back_button.dart';

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
  final Map<int, List<Uint8List?>> capturedImages = {};
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.3); // Adjust speed for kids
  }

  Future<void> _loadTasks() async {
    final loaded = await TaskService.getTasksForLevel(widget.level);
    if (mounted) setState(() => tasks = loaded);
  }
  
  Future<void> _speakWord() async {
    final word = tasks![currentTaskIndex];
    await _flutterTts.stop(); // stop any previous speech
    await _flutterTts.speak(word);
  }

  void _navigateTask(bool forward) {
    setState(() {
      if (forward && currentTaskIndex < (tasks!.length - 1)) currentTaskIndex++;
      if (!forward && currentTaskIndex > 0) currentTaskIndex--;
    });
  }

  Future<void> _submitTask() async {
    final word = tasks![currentTaskIndex];
    final images = capturedImages[currentTaskIndex] ?? [];

    if (images.length != word.length || images.contains(null)) {
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
      final files = await Future.wait(images.asMap().entries.map((e) async {
        final file = File('${dir.path}/char_${e.key}.png');
        await file.writeAsBytes(e.value!);
        return file;
      }));

      final result = await TaskService.predictTask(
        studentUid: widget.user['uid'],
        levelId: widget.level,
        taskId: currentTaskIndex,
        images: files,
      );

      if (context.mounted) Navigator.of(context).pop();

      if (result != null) {
        _showResultDialog(
          correct: result['correct'] == true,
          predicted: result['predicted_word'],
          expected: result['target_word'],
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final word = tasks![currentTaskIndex];

return Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        Expanded(
          flex: 11,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/homescreen/background_image.png',
                  fit: BoxFit.cover,
                ),
              ),
              Container(color: const Color.fromARGB(59, 0, 0, 0)),
              Positioned(
                top: 20,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AnimatedBackButton(
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 80.0), // leave space for back button
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: (currentTaskIndex + 1) / tasks!.length,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.volume_up, size: 32),
                                  onPressed: _speakWord,
                                  tooltip: 'Listen to the word',
                                ),
                                const Text("Tap to hear"),
                              ],
                            ),
                            Wrap(
                              spacing: 20,
                              children: List.generate(word.length, (i) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    DrawableCanvas(
                                      size: 64,
                                      onCapture: (bytes) {
                                        capturedImages[currentTaskIndex] ??=
                                            List.filled(word.length, null);
                                        capturedImages[currentTaskIndex]![i] = bytes;
                                      },
                                    ),
                                  ],
                                );
                              }),
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
                            onPressed: currentTaskIndex > 0
                                ? () => _navigateTask(false)
                                : null,
                            child: const Text('Previous'),
                          ),
                          ElevatedButton(
                            onPressed: _submitTask,
                            child: const Text('Submit'),
                          ),
                          ElevatedButton(
                            onPressed: currentTaskIndex < tasks!.length - 1
                                ? () => _navigateTask(true)
                                : null,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
  }
}