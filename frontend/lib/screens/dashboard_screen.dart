import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic> stats = {};
  List<dynamic> students = [];
  Map<String, dynamic> levels = {};
  bool isLoading = true;
  int selectedTab = 0;

  final String baseUrl = dotenv.env['BASE_URL']!;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    setState(() => isLoading = true);
    try {
      await Future.wait([
        loadStats(),
        loadStudents(),
        loadLevels(),
      ]);
    } catch (e) {
      _showError('Failed to load dashboard data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/stats'));
      if (response.statusCode == 200) {
        setState(() {
          stats = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<void> loadStudents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/students'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          students = data['students'] ?? [];
        });
      }
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  Future<void> loadLevels() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/levels'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          levels = data['levels'] ?? {};
        });
      }
    } catch (e) {
      print('Error loading levels: $e');
    }
  }

  Future<void> deleteStudent(String uid, String nickname) async {
    final confirmed = await _showConfirmDialog(
      'Delete Student',
      'Are you sure you want to delete $nickname? This action cannot be undone.',
    );
    
    if (confirmed) {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/admin/students/$uid'),
        );
        if (response.statusCode == 200) {
          _showSuccess('Student deleted successfully');
          loadStudents();
        } else {
          _showError('Failed to delete student');
        }
      } catch (e) {
        _showError('Error deleting student: $e');
      }
    }
  }

  Future<void> updateLevel(String levelId, List<String> tasks, List<String> translations) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/levels/$levelId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'tasks': tasks,
          'translations': translations,
        }),
      );
      
      if (response.statusCode == 200) {
        _showSuccess('Level updated successfully');
        loadLevels(); // Refresh levels
      } else {
        _showError('Failed to update level');
      }
    } catch (e) {
      _showError('Error updating level: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showEditLevelDialog(String levelId, Map<String, dynamic> levelData) {
    final tasksController = TextEditingController(
      text: (levelData['tasks'] as List).join(', '),
    );
    final translationsController = TextEditingController(
      text: (levelData['translations'] as List).join(', '),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Level $levelId'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tasksController,
                decoration: const InputDecoration(
                  labelText: 'Tasks (comma-separated)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: translationsController,
                decoration: const InputDecoration(
                  labelText: 'Translations (comma-separated)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final tasks = tasksController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              final translations = translationsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              
              if (tasks.length != translations.length) {
                _showError('Tasks and translations must have the same count');
                return;
              }
              
              Navigator.pop(context);
              updateLevel(levelId, tasks, translations);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/homescreen/background_image.png',
                fit: BoxFit.fill,
              ),
            ),
            Container(color: const Color.fromARGB(59, 0, 0, 0)),
            Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Welcome Admin (AID: ${widget.user['aid']})',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: loadDashboardData,
                            icon: const Icon(Icons.refresh, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _authService.logout();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => LoginScreen()),
                              );
                            },
                            icon: const Icon(Icons.logout, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stats Cards
                if (!isLoading) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(child: _buildStatCard('Total Students', stats['total_students']?.toString() ?? '0', Icons.people)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatCard('Active Students', stats['active_students']?.toString() ?? '0', Icons.people_alt)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatCard('Total Levels', stats['total_levels']?.toString() ?? '0', Icons.layers)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatCard('Stars Awarded', stats['total_stars_awarded']?.toString() ?? '0', Icons.star)),
                      ],
                    ),
                  ),
                ],

                // Tab Navigation
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedTab == 0 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              'Students',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selectedTab == 0 ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedTab == 1 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              'Levels',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selectedTab == 1 ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : selectedTab == 0
                            ? _buildStudentsTab()
                            : _buildLevelsTab(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Students (${students.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: loadStudents,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      student['nickname'][0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(student['nickname']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SID: ${student['sid']}'),
                      Text('Level ${student['current_level']} • ${student['total_stars']} stars'),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => deleteStudent(student['uid'], student['nickname']),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLevelsTab() {
    final levelsList = levels.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Levels (${levels.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: loadLevels,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: levelsList.length,
            itemBuilder: (context, index) {
              final levelEntry = levelsList[index];
              final levelId = levelEntry.key;
              final levelData = levelEntry.value;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ExpansionTile(
                  title: Text('Level $levelId'),
                  subtitle: Text('${levelData['tasks']?.length ?? 0} tasks'),
                  trailing: IconButton(
                    onPressed: () => _showEditLevelDialog(levelId, levelData),
                    icon: const Icon(Icons.edit),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tasks:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...List.generate(
                            levelData['tasks']?.length ?? 0,
                            (i) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Row(
                                children: [
                                  Text('${i + 1}. ${levelData['tasks'][i]}'),
                                  const Text(' → '),
                                  Text(levelData['translations'][i]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}