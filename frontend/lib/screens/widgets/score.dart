import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/websocket_service.dart';

class ScoreWidget extends StatefulWidget {
  final String userId;
  final String nickname;
  final int initialStars;

  const ScoreWidget({
    Key? key,
    required this.userId,
    required this.nickname,
    this.initialStars = 0,
  }) : super(key: key);

  @override
  State<ScoreWidget> createState() => _ScoreWidgetState();
}

class _ScoreWidgetState extends State<ScoreWidget> {
  late WebSocketService _webSocketService;
  StreamSubscription<Map<String, dynamic>>? _scoreSubscription;
  int _totalStars = 0;

  @override
  void initState() {
    super.initState();
    _totalStars = widget.initialStars;
    _webSocketService = WebSocketService();
    _connectToWebSocket();
  }

  void _connectToWebSocket() async {
    try {
      await _webSocketService.connectToScoreUpdates();
      _scoreSubscription = _webSocketService.scoreUpdates.listen((data) {
        final userId = data['user_id']?.toString();
        if (userId == widget.userId) {
          setState(() {
            _totalStars = data['total_stars'] ?? _totalStars;
          });
        }
      });
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
    }
  }

  @override
  void dispose() {
    _scoreSubscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Container(
    width: 60,
    height: 35,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/blue_button_rectangle_gradient.png'),
        fit: BoxFit.fill,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/yellow_star.png',
          width: 22,
          height: 22,
        ),
        SizedBox(width: 8),
        Text(
          '$_totalStars',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ],
    ),
  );
}
}