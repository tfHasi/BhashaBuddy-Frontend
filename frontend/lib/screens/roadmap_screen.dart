import 'package:flutter/material.dart';

class RoadMapScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  RoadMapScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    // Calculate available height (excluding status bar and leaving 10% space at bottom)
    final availableHeight = screenHeight - statusBarHeight;
    final double imageHeight = availableHeight * 0.925;

    return Scaffold(
      // Remove default AppBar
      body: Stack(
        children: [
          // Add top padding to avoid status bar
          Padding(
            padding: EdgeInsets.only(top: statusBarHeight*0.8),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Stack(
                children: [
                  // Base Map Image - full width, calculated height
                  SizedBox(
                    width: screenWidth,
                    height: imageHeight,
                    child: Image.asset(
                      'assets/images/map.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Add more Positioned widgets for other level markers
                ],
              ),
            ),
          ),
          // Overlay AppBar on top of the image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                // Semi-transparent background for better visibility
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Map',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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