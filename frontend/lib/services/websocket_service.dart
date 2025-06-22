import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketService {
 static final String wsUrl = dotenv.env['WS_URL'] ?? 'ws://10.0.2.2:8000';

 WebSocketChannel? _scoreChannel;
 WebSocketChannel? _leaderboardChannel;

 final _scoreController = StreamController<Map<String, dynamic>>.broadcast();
 final _leaderboardController = StreamController<List<dynamic>>.broadcast();

 Stream<Map<String, dynamic>> get scoreUpdates => _scoreController.stream;
 Stream<List<dynamic>> get leaderboardUpdates => _leaderboardController.stream;

 bool _isConnected = false;
 bool get isConnected => _isConnected;

 Timer? _heartbeatTimer;

 Future<void> connectToScoreUpdates() async {
   try {
     _scoreChannel = WebSocketChannel.connect(Uri.parse('$wsUrl/ws/score_updates'));
     _scoreChannel!.stream.listen(
       (data) {
         try {
           _scoreController.add(json.decode(data));
         } catch (_) {}
       },
       onError: (_) => _reconnectScoreUpdates(),
       onDone: () => _reconnectScoreUpdates(),
     );
     _isConnected = true;
   } catch (_) {
     _reconnectScoreUpdates();
   }
 }

 Future<void> connectToLeaderboard() async {
   try {
     _leaderboardChannel = WebSocketChannel.connect(Uri.parse('$wsUrl/ws/leaderboard'));
     _leaderboardChannel!.stream.listen(
       (data) {
         try {
           final jsonData = json.decode(data);
           if (jsonData['top5'] != null) _leaderboardController.add(jsonData['top5']);
         } catch (_) {}
       },
       onError: (_) => _reconnectLeaderboard(),
       onDone: () => _reconnectLeaderboard(),
     );
   } catch (_) {
     _reconnectLeaderboard();
   }
 }

 void _reconnectScoreUpdates() async {
   await Future.delayed(Duration(seconds: 5));
   if (!_scoreController.isClosed) connectToScoreUpdates();
 }

 void _reconnectLeaderboard() async {
   await Future.delayed(Duration(seconds: 5));
   if (!_leaderboardController.isClosed) connectToLeaderboard();
 }

 void startHeartbeat() {
   _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (_) {
     _scoreChannel?.sink.add('ping');
     _leaderboardChannel?.sink.add('ping');
   });
 }

 void disconnect() {
   _heartbeatTimer?.cancel();
   _scoreChannel?.sink.close(status.goingAway);
   _leaderboardChannel?.sink.close(status.goingAway);
   _scoreChannel = null;
   _leaderboardChannel = null;
   _isConnected = false;
 }

 void dispose() {
   disconnect();
   _scoreController.close();
   _leaderboardController.close();
 }
}