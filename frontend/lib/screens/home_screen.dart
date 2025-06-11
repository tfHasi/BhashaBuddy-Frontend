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
        title: const Text('WordWiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Outer background container with MENU
            Image.asset(
              'assets/images/homescreen/red_button_full.png',
              height: 60,
              width: 125,
              fit: BoxFit.fill,
            ),
            // Content inside the wrapper
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MENU',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 15),
                  // Square border background with buttons
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/homescreen/blue_button_border.png',
                        height: 280,
                        width: 280,
                        fit: BoxFit.cover,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMenuButton(
                            context,
                            label: 'Play',
                            icon: Icons.map,
                            textColor: Colors.white,
                            iconColor: Colors.white,
                            imagePath:
                                'assets/images/homescreen/red_button_depth_gradient.png',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => RoadMapScreen(user: user)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildMenuButton(
                            context,
                            label: 'Settings',
                            icon: Icons.settings,
                            imagePath:
                                'assets/images/homescreen/red_button_border_depth.png',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SettingsScreen(user: user)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildMenuButton(
                            context,
                            label: 'Leaderboard',
                            icon: Icons.leaderboard,
                            imagePath:
                                'assets/images/homescreen/red_button_border_depth.png',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      LeaderboardScreen(user: user)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildMenuButton(
                            context,
                            label: 'Credits',
                            icon: Icons.star,
                            imagePath:
                                'assets/images/homescreen/red_button_border_depth.png',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => CreditsScreen(user: user)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildMenuButton(
  BuildContext context, {
  required String label,
  required IconData icon,
  required String imagePath,
  required VoidCallback onPressed,
  Color textColor = const Color.fromARGB(255, 148, 148, 148),
  Color iconColor = const Color.fromARGB(255, 148, 148, 148),
}) {
  return InkWell(
    onTap: onPressed,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          imagePath,
          height: 45,
          width: 175,
          fit: BoxFit.fill,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}