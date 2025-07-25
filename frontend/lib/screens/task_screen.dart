import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/task_service.dart';
import './widgets/canvas_overlay.dart';
import './widgets/back_button.dart';
import './widgets/speak_buttons.dart';

class TaskScreen extends StatefulWidget {
  final int level;
  final Map<String, dynamic> user;

  const TaskScreen({super.key, required this.level, required this.user});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<String>? tasks;
  List<String>? translations;
  int currentTab = 0;
  final Map<int, List<Uint8List?>> images = {};
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadLevelData();
    tts.setLanguage("en-US");
    tts.setSpeechRate(0.3);
  }

  Future<void> _loadLevelData() async {
    // Load complete level data (tasks + translations)
    final levelData = await TaskService.getLevelData(widget.level);
    if (mounted && levelData != null) {
      setState(() {
        tasks = List<String>.from(levelData['tasks'] ?? []);
        translations = levelData.containsKey('translations') 
            ? List<String>.from(levelData['translations']) 
            : null;
      });
    }
  }

  Future<void> _submit() async {
    if (tasks?.isEmpty != false) return;
    
    final word = tasks![currentTab];
    final imgs = images[currentTab] ?? [];

    if (imgs.length != word.length || imgs.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw all characters')),
      );
      return;
    }

    _showDialog('Please Wait..', loading: true);

    try {
      final dir = await getTemporaryDirectory();
      final files = await Future.wait(imgs.asMap().entries.map((e) async {
        final file = File('${dir.path}/char_${e.key}.png');
        await file.writeAsBytes(e.value!);
        return file;
      }));

      final result = await TaskService.predictTask(
        studentUid: widget.user['uid'],
        levelId: widget.level,
        taskId: currentTab,
        images: files,
      );

      if (mounted) {
        Navigator.pop(context);
        if (result != null) {
          _showDialog(
            result['correct'] == true ? 'Correct!' : 'Try Again',
            content: 'Your: ${result['predicted_word']}\nExpected: ${result['target_word']}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showDialog(String title, {String? content, bool loading = false}) {
    showDialog(
      context: context,
      barrierDismissible: !loading,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: loading 
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Checking..')],
            )
          : content != null ? Text(content) : null,
        actions: loading ? null : [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openCanvasOverlay(int charIndex) {
    if (tasks == null) return;
    
    final word = tasks![currentTab];
    showDialog(
      context: context,
      builder: (_) => CanvasOverlay(
        onSave: (bytes) {
          images[currentTab] ??= List.filled(word.length, null);
          images[currentTab]![charIndex] = bytes;
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tasks == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final word = tasks!.isNotEmpty ? tasks![currentTab] : '';
    final translation = translations != null && translations!.length > currentTab 
        ? translations![currentTab] 
        : null;
    final taskImages = images[currentTab] ?? [];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset('assets/images/homescreen/background_image.png', fit: BoxFit.cover),
            ),
            Container(color: Colors.black26),
            
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      AnimatedBackButton(onTap: () => Navigator.pop(context)),
                      const SizedBox(width: 16),
                      Text('Level ${widget.level}', 
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                
                // Tabs
                if (tasks!.length > 1) _buildTabs(),
                
                // Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        // Speak Buttons
                        SpeakButtons(
                          englishWord: word,
                          sinhalaWord: translation,
                          tts: tts,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Drawing boxes
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: List.generate(word.length, (i) {
                            final image = taskImages.length > i ? taskImages[i] : null;
                            return GestureDetector(
                              onTap: () => _openCanvasOverlay(i),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade50,
                                ),
                                child: image != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(image, fit: BoxFit.cover),
                                      )
                                    : const Icon(Icons.edit, size: 28, color: Colors.grey),
                              ),
                            );
                          }),
                        ),
                        
                        const Spacer(),
                        
                        // Submit button
                        GestureDetector(
                          onTap: _submit,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/blue_button_rectangle_gradient.png'),
                                fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                ),
                              alignment: Alignment.center,
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final tabCount = tasks!.length > 3 ? 3 : tasks!.length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(tabCount, (i) {
          final selected = i == currentTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => currentTab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF4A9EFF) : Colors.grey.shade200,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(i == 0 ? 8 : 0),
                    right: Radius.circular(i == tabCount - 1 ? 8 : 0),
                  ),
                  border: i > 0 ? const Border(left: BorderSide(color: Colors.white)) : null,
                ),
                child: Text(
                  'Task ${i + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }
}