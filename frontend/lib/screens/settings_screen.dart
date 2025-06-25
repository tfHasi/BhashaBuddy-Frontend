import 'package:flutter/material.dart';
import './widgets/bottom_navbar.dart';
import './widgets/back_button.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
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
                  // Header
                  Positioned(
                    top: 20,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AnimatedBackButton(
                              onTap: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Positioned(
                    top: 80,
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // How to Play
                          _buildCard(
                            '🎮 How to Play?',
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Welcome to Bhasha Buddy! Here\'s how to play:', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 12),
                                _buildStep('1', 'Listen to the word', 'Tap the speaker button to hear the word you need to spell.'),
                                _buildStep('2', 'Count the letters', 'You\'ll see empty boxes - one for each letter in the word.'),
                                _buildStep('3', 'Write capital letters', 'Write each letter in CAPITAL LETTERS only (A, B, C...).'),
                                _buildStep('4', 'Fill each box', 'Write one letter in each box to spell the complete word.'),
                                _buildStep('5', 'Submit your answer', 'When all boxes are filled, tap submit to check your spelling!'),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.lightbulb, color: Colors.yellow, size: 20),
                                      SizedBox(width: 8),
                                      Expanded(child: Text('Tip: You can replay the word as many times as you need!', style: TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Account
                          if (widget.user['type'] == 'student')
                            _buildCard(
                              'Account',
                              Column(
                                children: [
                                  _buildInfoRow('Student Name', widget.user['nickname']?.toString() ?? 'User'),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await AuthService().logout();
                                      Navigator.pushReplacement(
                                        context,
                                      MaterialPageRoute(builder: (_) => LoginScreen()),
                                      );
                                    },
                                    icon: const Icon(Icons.logout),
                                   label: const Text('Logout'),),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),
                          // About
                          _buildCard(
                            'About',
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bhasha Buddy v1.0', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                SizedBox(height: 8),
                                Text('A fun and educational app designed to help children improve their spelling through interactive dictation exercises.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: BottomNavBar(currentRoute: 'settings', user: widget.user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}