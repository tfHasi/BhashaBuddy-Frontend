import 'package:flutter/material.dart';

class RoadMapScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  RoadMapScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Use 90% of screen height (leaving 10% space at bottom)
    final double imageHeight = screenHeight * 0.9;

    return Scaffold(
      // Remove default AppBar
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Stack(
              children: [
                // Base Map Image - full width, 90% height
                SizedBox(
                  width: screenWidth,
                  height: imageHeight,
                  child: Image.asset(
                    'assets/images/map.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Example Positioned level icon (adjust top/left accordingly)
                Positioned(
                  top: imageHeight * 0.2, // 20% from top
                  left: screenWidth * 0.3, // 30% from left
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to level
                    },
                    child: Icon(Icons.star, color: Colors.yellow, size: 40),
                  ),
                ),
                // Add more Positioned widgets for other level markers
              ],
            ),
          ),
          // Overlay AppBar on top of the image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              // Add padding for status bar
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              decoration: BoxDecoration(
                // Semi-transparent background for better visibility
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Road Map',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                iconTheme: const IconThemeData(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}