import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; 
import 'main.dart'; 

// ==========================================
// ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ДЛЯ ОЗВУЧКИ
// ==========================================
final ValueNotifier<bool> autoVoiceNotifier = ValueNotifier(false);
final FlutterTts globalTts = FlutterTts(); 

class InclusiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onSpeak; 

  const InclusiveAppBar({
    super.key, 
    required this.title, 
    this.showBackButton = false,
    this.onSpeak, 
  });

  Future<void> _toggleVoiceMode(BuildContext context, bool currentState) async {
    autoVoiceNotifier.value = !currentState;
    bool isEnabled = autoVoiceNotifier.value;

    await globalTts.setLanguage("ru-RU");
    await globalTts.setSpeechRate(0.65); 
    await globalTts.setPitch(1.0); 

    if (isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Голосовой режим ВКЛЮЧЕН'), backgroundColor: Colors.green, duration: Duration(seconds: 1))
      );
      
      if (onSpeak != null) {
        onSpeak!();
      } else {
        await globalTts.speak("Голосовой режим включен. Экран: $title.");
      }
    } else {
      globalTts.stop(); 
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Голосовой режим ВЫКЛЮЧЕН'), backgroundColor: Colors.grey, duration: Duration(seconds: 1))
      );
      await globalTts.speak("Голосовой режим выключен.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: autoVoiceNotifier,
      builder: (context, isVoiceEnabled, child) {
        return AppBar(
          // ВЕРНУЛИ ЛОГОТИП ИЗ ПАПКИ ASSETS!
          leading: showBackButton 
              ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))
              : Padding(
                  padding: const EdgeInsets.all(8.0), // Отступы, чтобы логотип не прилипал к краям
                  child: Image.asset(
                    'assets/logo.png', // <-- ВНИМАНИЕ: Если твой файл называется иначе, поменяй тут!
                    fit: BoxFit.contain,
                  ),
                ),
          title: Text(title),
          actions: [
            IconButton(
              icon: Icon(
                isVoiceEnabled ? Icons.record_voice_over : Icons.volume_off, 
                color: isVoiceEnabled ? Colors.green : Colors.blue
              ),
              tooltip: 'Голосовой помощник',
              onPressed: () => _toggleVoiceMode(context, isVoiceEnabled),
            ),
            IconButton(
              icon: const Text('A-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: () {
                if (textScaleNotifier.value > 0.8) textScaleNotifier.value -= 0.1;
              },
            ),
            IconButton(
              icon: const Text('A+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              onPressed: () {
                if (textScaleNotifier.value < 1.6) textScaleNotifier.value += 0.1;
              },
            ),
            const SizedBox(width: 8),
          ],
        );
      }
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}