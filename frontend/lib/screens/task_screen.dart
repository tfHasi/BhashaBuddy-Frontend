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
  Map<int, List<Uint8List?>> capturedImages = {};
  Map<int, bool> completedTasks = {};
  
  int currentTaskIndex = 0;
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final loaded = await TaskService.getTasksForLevel(widget.level);
    if (loaded != null) {
      setState(() {
        tasks = loaded;
        // Initialize captured images map
        for (int i = 0; i < loaded.length; i++) {
          capturedImages[i] = List.filled(loaded[i].length, null);
          completedTasks[i] = false;
        }
      });
    }
  }

  void _navigateToTask(int index) {
    if (index >= 0 && index < tasks!.length) {
      setState(() {
        currentTaskIndex = index;
      });
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextTask() {
    if (currentTaskIndex < tasks!.length - 1) {
      _navigateToTask(currentTaskIndex + 1);
    }
  }

  void _previousTask() {
    if (currentTaskIndex > 0) {
      _navigateToTask(currentTaskIndex - 1);
    }
  }

  Future<void> _submitTask(int taskIndex) async {
    final images = capturedImages[taskIndex];
    if (images == null) {
      _showSnackBar('Please draw and capture all characters');
      return;
    }

    // Check if all images are captured and not empty
    List<int> missingIndices = [];
    for (int i = 0; i < images.length; i++) {
      if (images[i] == null || images[i]!.isEmpty || images[i]!.length < 100) {
        missingIndices.add(i + 1);
      }
    }
    
    if (missingIndices.isNotEmpty) {
      _showSnackBar('Please draw and tap ✓ for character(s): ${missingIndices.join(', ')}');
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Analyzing your drawings...'),
          ],
        ),
      ),
    );

    try {
      // Save images temporarily
      final dir = await getTemporaryDirectory();
      List<File> files = [];
      
      for (int i = 0; i < images.length; i++) {
        final file = File('${dir.path}/task_${taskIndex}_char_$i.png');
        await file.writeAsBytes(images[i]!);
        files.add(file);
        
        // Debug: Print file size
        print('Image $i size: ${images[i]!.length} bytes');
      }

      final result = await TaskService.predictTask(
        studentUid: widget.user['uid'],
        levelId: widget.level,
        taskId: taskIndex,
        images: files,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (result != null) {
        final correct = result['correct'] == true;
        
        // Mark task as completed if correct
        if (correct) {
          setState(() {
            completedTasks[taskIndex] = true;
          });
        }
        
        _showResultDialog(
          correct: correct,
          predicted: result['predicted_word'],
          expected: result['target_word'],
          onNext: correct && taskIndex < tasks!.length - 1 ? _nextTask : null,
        );
        
        // Clean up temporary files
        for (final file in files) {
          try { await file.delete(); } catch (e) { /* ignore */ }
        }
      } else {
        _showSnackBar('Failed to analyze drawings. Please try again.');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showSnackBar('Error: ${e.toString()}');
      print('Submit error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showResultDialog({
    required bool correct,
    required String predicted,
    required String expected,
    VoidCallback? onNext,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(
              correct ? Icons.check_circle : Icons.error,
              color: correct ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(correct ? "Excellent!" : "Try Again"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your answer: $predicted",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Expected: $expected",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (!correct) ...[
              const SizedBox(height: 12),
              const Text(
                "💡 Tip: Make sure your letters are clear and well-formed!",
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.orange),
              ),
            ],
          ],
        ),
        actions: [
          if (!correct)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Try Again'),
            ),
          if (correct && onNext != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onNext();
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Task'),
            ),
          if (correct && onNext == null)
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.celebration),
              label: const Text('Great Job!'),
            ),
        ],
      ),
    );
  }

  void _clearCurrentTask() {
    setState(() {
      if (tasks != null) {
        capturedImages[currentTaskIndex] = List.filled(tasks![currentTaskIndex].length, null);
        completedTasks[currentTaskIndex] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (tasks == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Level ${widget.level}'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Progress indicator
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${currentTaskIndex + 1}/${tasks!.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            height: 8,
            margin: const EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: (currentTaskIndex + 1) / tasks!.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          
          // Task dots indicator
          Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(tasks!.length, (index) {
                final isCompleted = completedTasks[index] == true;
                final isCurrent = index == currentTaskIndex;
                
                return GestureDetector(
                  onTap: () => _navigateToTask(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isCurrent ? 12 : 8,
                    height: isCurrent ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted 
                          ? Colors.green
                          : isCurrent 
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                    ),
                    child: isCompleted 
                        ? const Icon(Icons.check, color: Colors.white, size: 6)
                        : null,
                  ),
                );
              }),
            ),
          ),

          // Main task content
          Expanded(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentTaskIndex = index;
                });
              },
              itemCount: tasks!.length,
              itemBuilder: (context, taskIndex) {
                return _buildTaskCard(taskIndex);
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                ElevatedButton.icon(
                  onPressed: currentTaskIndex > 0 ? _previousTask : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                  ),
                ),

                // Clear button
                OutlinedButton.icon(
                  onPressed: _clearCurrentTask,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear All'),
                ),

                // Next button
                ElevatedButton.icon(
                  onPressed: currentTaskIndex < tasks!.length - 1 ? _nextTask : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(int taskIndex) {
    final word = tasks![taskIndex];
    final charCount = word.length;
    final isCompleted = completedTasks[taskIndex] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Task header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Task ${taskIndex + 1}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isCompleted) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle, color: Colors.green, size: 28),
                  ],
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Word to draw
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  word.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Draw each letter and tap ✓ to capture:',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Character drawing boxes
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: List.generate(charCount, (charIndex) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          word[charIndex].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DrawableCanvas(
                        size: 100,
                        onCapture: (bytes) {
                          capturedImages[taskIndex] ??= List.filled(charCount, null);
                          capturedImages[taskIndex]![charIndex] = bytes;
                          print('Captured image for task $taskIndex, char $charIndex: ${bytes.length} bytes');
                        },
                      ),
                    ],
                  );
                }),
              ),
              
              const SizedBox(height: 32),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _submitTask(taskIndex),
                  icon: const Icon(Icons.send),
                  label: Text(
                    'Submit ${word.toUpperCase()}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Progress for this task
              Text(
                'Progress: ${_getCompletedCount(taskIndex)}/$charCount characters captured',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCompletedCount(int taskIndex) {
    final images = capturedImages[taskIndex];
    if (images == null) return 0;
    return images.where((img) => img != null && img.isNotEmpty && img.length >= 100).length;
  }
}