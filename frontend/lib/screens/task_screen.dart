import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/task_service.dart';
import './widgets/canvas_overlay.dart';
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
  int currentTabIndex = 0;
  final Map<int, List<Uint8List?>> capturedImages = {};
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.3);
  }

  Future<void> _loadTasks() async {
    final loaded = await TaskService.getTasksForLevel(widget.level);
    if (mounted) setState(() => tasks = loaded);
  }

  Future<void> _speakWord() async {
    if (tasks == null || tasks!.isEmpty) return;
    final word = tasks![currentTabIndex];
    await _flutterTts.stop();
    await _flutterTts.speak(word);
  }

  Future<void> _submitTask() async {
    if (tasks == null || tasks!.isEmpty) return;
    
    final word = tasks![currentTabIndex];
    final images = capturedImages[currentTabIndex] ?? [];

    if (images.length != word.length || images.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw all characters')),
      );
      return;
    }

    _showLoadingDialog();

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
        taskId: currentTabIndex,
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

  void _showLoadingDialog() {
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

  void _openCanvasOverlay(int charIndex) {
    if (tasks == null) return;
    
    final word = tasks![currentTabIndex];
    showDialog(
      context: context,
      builder: (_) => CanvasOverlay(
        onSave: (bytes) {
          capturedImages[currentTabIndex] ??= List.filled(word.length, null);
          capturedImages[currentTabIndex]![charIndex] = bytes;
          setState(() {});
        },
      ),
    );
  }

  Widget _buildTabBar() {
    if (tasks == null) return const SizedBox.shrink();
    
    final tabCount = tasks!.length > 3 ? 3 : tasks!.length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(tabCount, (index) {
          final isSelected = index == currentTabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => currentTabIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Task ${index + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTaskContent() {
    if (tasks == null || currentTabIndex >= tasks!.length) {
      return const Center(child: Text('No task available'));
    }

    final word = tasks![currentTabIndex];
    
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TTS Button
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 40, color: Colors.blue),
                  onPressed: _speakWord,
                  tooltip: 'Listen to the word',
                ),
                const Text(
                  "Tap to hear",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Drawing Boxes
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: List.generate(word.length, (i) {
                final image = capturedImages[currentTabIndex]?[i];
                
                return GestureDetector(
                  onTap: () => _openCanvasOverlay(i),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(image, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.edit, size: 24, color: Colors.grey),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 40),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/homescreen/background_image.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(color: const Color.fromARGB(59, 0, 0, 0)),
            
            // Content
            Column(
              children: [
                // Header with Back Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      AnimatedBackButton(
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                
                // Level Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Level ${widget.level}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tab Bar
                _buildTabBar(),
                
                // Task Content
                _buildTaskContent(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}