import 'package:flutter/material.dart';
import '../services/task_service.dart';

class TaskScreen extends StatefulWidget {
  final int level;
  final Map<String, dynamic> user;

  const TaskScreen({super.key, required this.level, required this.user});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<dynamic>? tasks;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final fetchedTasks = await TaskService.getTasksForLevel(widget.level);
    if (fetchedTasks != null) {
      setState(() => tasks = fetchedTasks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level} Tasks'),
      ),
      body: tasks == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tasks!.length,
              itemBuilder: (context, index) {
                final word = tasks![index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text('Task ${index + 1}: $word'),
                    subtitle: Row(
                      children: List.generate(word.length, (i) {
                        return Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          color: Colors.grey[300],
                          child: const Icon(Icons.edit), // for character input box
                        );
                      }),
                    ),
                    trailing: ElevatedButton(
                      child: const Text("Submit"),
                      onPressed: () {
                        // TODO: handle image upload and inference here
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}