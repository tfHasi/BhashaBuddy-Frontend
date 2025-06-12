import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'roadmap_screen.dart';
import 'credits_screen.dart';
import './widgets/bottom_navbar.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final AuthService _authService = AuthService();

  HomeScreen({required this.user});

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
          Center(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Content inside the wrapper
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 80),
                      // Square border background with buttons
                      Stack(
                        alignment: Alignment.center,
                        children: [
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
                              const SizedBox(height: 12),
                              // Optional: Logout button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await _authService.logout();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => LoginScreen()),
                                  );
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Logout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
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
        ],
      ),
      ),
      bottomNavigationBar: BottomNavBar(currentRoute: 'home', user: user),
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
            height: 50,
            width: 140,
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
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}