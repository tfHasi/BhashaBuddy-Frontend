import 'package:flutter/material.dart';
import '../home_screen.dart';
import '../leaderboard_screen.dart';
import '../roadmap_screen.dart';
import '../settings_screen.dart';

class BottomNavBar extends StatelessWidget {
  final String currentRoute;
  final Map<String, dynamic> user;

  const BottomNavBar({
    Key? key,
    required this.currentRoute,
    required this.user,
  }) : super(key: key);

  void _navigate(BuildContext context, String targetRoute) {
    if (targetRoute == currentRoute) return;

    Widget screen;
    switch (targetRoute) {
      case 'home':
        screen = HomeScreen(user: user);
        break;
      case 'leaderboard':
        screen = LeaderboardScreen(user: user);
        break;
      case 'roadmap':
        screen = RoadMapScreen(user: user);
        break;
      case 'settings':
        screen = SettingsScreen(user: user);
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(context, Icons.person, 'Profile', 'home'),
          _buildNavItem(context, Icons.leaderboard, 'Leaderboard', 'leaderboard'),
          _buildNavItem(context, Icons.map, 'Map', 'roadmap'),
          _buildNavItem(context, Icons.settings, 'Settings', 'settings'),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    final isSelected = (route == currentRoute);

    return GestureDetector(
      onTap: () => _navigate(context, route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}