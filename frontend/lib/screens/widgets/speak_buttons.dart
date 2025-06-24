import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeakButtons extends StatelessWidget {
  final String englishWord;
  final String? sinhalaWord;
  final FlutterTts tts;

  const SpeakButtons({
    super.key,
    required this.englishWord,
    this.sinhalaWord,
    required this.tts,
  });

  Future<void> _speakEnglish() async {
    await tts.stop();
    await tts.setLanguage("en-US");
    await tts.speak(englishWord);
  }

  Future<void> _speakSinhala() async {
    if (sinhalaWord != null) {
      await tts.stop();
      await tts.setLanguage("si-LK");
      await tts.speak(sinhalaWord!);
      await tts.setSpeechRate(0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // English speak button
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4A9EFF),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: const Color(0xFF4A9EFF).withOpacity(0.3),
                  blurRadius: 8,
                )],
              ),
              child: IconButton(
                icon: const Icon(Icons.volume_up, size: 28, color: Colors.white),
                onPressed: _speakEnglish,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'English',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        
        // Sinhala speak button
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B4A),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: const Color(0xFFFF6B4A).withOpacity(0.3),
                  blurRadius: 8,
                )],
              ),
              child: IconButton(
                icon: const Icon(Icons.record_voice_over, size: 28, color: Colors.white),
                onPressed: _speakSinhala,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'සිංහල',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}