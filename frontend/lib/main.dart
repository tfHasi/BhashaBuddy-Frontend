import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart';
import 'services/websocket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final ws = WebSocketService();
  await ws.connectToScoreUpdates();
  await ws.connectToLeaderboard();
  ws.startHeartbeat();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordWiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Fredoka',
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}