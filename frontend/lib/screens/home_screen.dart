import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'roadmap_screen.dart';
import 'leaderboard_screen.dart';
import 'credits_screen.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final AuthService _authService = AuthService();

  HomeScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WordWiz'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'MENU', 
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: 80),
            Center(
              child: SizedBox(
                width: 200, // Fixed width for consistent button sizing
                child: ElevatedButton.icon(
                  icon: Icon(Icons.map),
                  label: Text(
                    'Play',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RoadMapScreen(user: user)),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.settings),
                  label: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SettingsScreen(user: user)),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.leaderboard),
                  label: Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LeaderboardScreen(user: user)),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.star),
                  label: Text(
                    'Credits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CreditsScreen(user: user)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}