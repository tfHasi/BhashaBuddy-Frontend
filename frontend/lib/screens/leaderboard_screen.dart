import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import './widgets/bottom_navbar.dart';
import './widgets/back_button.dart';
import '../services/websocket_service.dart';
import '../services/progress_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const LeaderboardScreen({super.key, required this.user});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final WebSocketService _webSocketService;
  StreamSubscription<List<dynamic>>? _leaderboardSubscription;
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService();
    _loadLeaderboard();
    _connectToWebSocket();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final data = await ProgressService.getLeaderboard();
      if (data != null && mounted) {
        setState(() {
          _leaderboardData = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading leaderboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _connectToWebSocket() async {
    try {
      await _webSocketService.connectToLeaderboard();
      _leaderboardSubscription = _webSocketService.leaderboardUpdates.listen((data) {
        if (mounted) {
          setState(() {
            _leaderboardData = List<Map<String, dynamic>>.from(data);
          });
        }
      });
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
  }

  @override
  void dispose() {
    _leaderboardSubscription?.cancel();
    super.dispose();
  }

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
                  // Background
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
                      children: [
                        AnimatedBackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Leaderboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Glassmorphism Leaderboard Content
                  Positioned(
                    top: 100,
                    left: 16,
                    right: 16,
                    bottom: 40,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1.5,
                            ),
                          ),
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ))
                              : _leaderboardData.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No players found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        // Header
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Row(
                                            children: [
                                              const SizedBox(width: 40),
                                              const Expanded(
                                                child: Text(
                                                  'Player',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/images/yellow_star.png',
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'Score',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(height: 12, color: Colors.white.withOpacity(0.3)),
                                        
                                        // Leaderboard List
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: _leaderboardData.length,
                                            itemBuilder: (context, index) {
                                              final player = _leaderboardData[index];
                                              final isCurrentUser = player['uid'] == widget.user['uid'];
                                              final rank = index + 1;
                                              
                                              return _buildLeaderboardItem(
                                                rank: rank,
                                                nickname: player['nickname'] ?? 'Unknown',
                                                totalStars: player['total_stars'] ?? 0,
                                                isCurrentUser: isCurrentUser,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: BottomNavBar(
                currentRoute: 'leaderboard',
                user: widget.user,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String nickname,
    required int totalStars,
    required bool isCurrentUser,
  }) {
    Color rankColor = Colors.white70;
    Widget rankWidget = Text(
      '$rank',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: rankColor,
      ),
    );

    // Special styling for top 3
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
      rankWidget = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: rankColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: rankColor.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '1',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 100, 100, 100),
            ),
          ),
        ),
      );
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
      rankWidget = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: rankColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: rankColor.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '2',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 100, 100, 100),
            ),
          ),
        ),
      );
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
      rankWidget = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: rankColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: rankColor.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '3',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? Colors.white.withOpacity(0.3) 
            : Colors.white.withOpacity(0.125),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser 
            ? Border.all(color: Colors.white.withOpacity(0.75), width: 1.5) 
            : Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: rankWidget,
          ),
          
          // Player Name
          Expanded(
            child: Text(
              nickname,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                color: isCurrentUser ? Colors.white : Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          
          // Score
          Row(
            children: [
              Image.asset(
                'assets/images/yellow_star.png',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$totalStars',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? Colors.white : Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}