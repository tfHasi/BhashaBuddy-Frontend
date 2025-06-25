import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  Map<String, dynamic> stats = {};
  List<dynamic> students = [];
  Map<String, dynamic> levels = {};
  bool isLoading = true;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        AdminService.getStats(),
        AdminService.getStudents(),
        AdminService.getLevels(),
      ]);
      setState(() {
        stats = results[0];
        students = results[1]['students'] ?? [];
        levels = results[2]['levels'] ?? {};
      });
    } catch (e) {
      _showSnackBar('Failed to load data: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteStudent(String uid, String nickname) async {
    if (await _showConfirmDialog('Delete $nickname?')) {
      try {
        if (await AdminService.deleteStudent(uid)) {
          _showSnackBar('Student deleted successfully');
          _loadData();
        } else {
          _showSnackBar('Failed to delete student', isError: true);
        }
      } catch (e) {
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  Future<void> _updateLevel(String levelId, List<String> tasks, List<String> translations) async {
    try {
      if (await AdminService.updateLevel(levelId, tasks, translations)) {
        _showSnackBar('Level updated successfully');
        _loadData();
      } else {
        _showSnackBar('Failed to update level', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<bool> _showConfirmDialog(String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showEditDialog(String levelId, Map<String, dynamic> levelData) {
    final tasksController = TextEditingController(text: (levelData['tasks'] as List).join(', '));
    final translationsController = TextEditingController(text: (levelData['translations'] as List).join(', '));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Level $levelId'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tasksController,
              decoration: const InputDecoration(labelText: 'Tasks (comma-separated)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: translationsController,
              decoration: const InputDecoration(labelText: 'Translations (comma-separated)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final tasks = tasksController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              final translations = translationsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              
              if (tasks.length != translations.length) {
                _showSnackBar('Tasks and translations must have same count', isError: true);
                return;
              }
              Navigator.pop(context);
              _updateLevel(levelId, tasks, translations);
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
            Positioned.fill(child: Image.asset('assets/images/homescreen/background_image.png', fit: BoxFit.fill)),
            Container(color: const Color.fromARGB(59, 0, 0, 0)),
            Column(
              children: [
                _buildHeader(),
                if (!isLoading) _buildStatsCards(),
                _buildTabNavigation(),
                _buildContent(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Welcome Admin (AID: ${widget.user['aid']})', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          Row(
            children: [
              IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh, color: Colors.white)),
              IconButton(
                onPressed: () async {
                  await _authService.logout();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                },
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final statData = [
      ('Total Students', stats['total_students'], Icons.people),
      ('Active Students', stats['active_students'], Icons.people_alt),
      ('Total Levels', stats['total_levels'], Icons.layers),
      ('Stars Awarded', stats['total_stars_awarded'], Icons.star),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: statData.map((data) => Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(data.$3, color: Colors.white, size: 20),
                const SizedBox(height: 2),
                Text('${data.$2 ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(data.$1, style: const TextStyle(color: Colors.white70, fontSize: 9), textAlign: TextAlign.center, maxLines: 2),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: ['Students', 'Levels'].asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == index ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedTab == index ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(16)),
        child: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : selectedTab == 0 ? _buildStudentsTab() : _buildLevelsTab(),
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Column(
      children: [
        _buildTabHeader('Students', students.length, () => _loadData()),
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
                    child: Text(student['nickname'][0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(student['nickname']),
                  subtitle: Text('SID: ${student['sid']}\nLevel ${student['current_level']} • ${student['total_stars']} stars'),
                  trailing: IconButton(
                    onPressed: () => _deleteStudent(student['uid'], student['nickname']),
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
    final levelsList = levels.entries.toList()..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

    return Column(
      children: [
        _buildTabHeader('Levels', levels.length, () => _loadData()),
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
                  trailing: IconButton(onPressed: () => _showEditDialog(levelId, levelData), icon: const Icon(Icons.edit)),
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
                              child: Text('${i + 1}. ${levelData['tasks'][i]} → ${levelData['translations'][i]}'),
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

  Widget _buildTabHeader(String title, int count, VoidCallback onRefresh) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$title ($count)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh)),
        ],
      ),
    );
  }
}