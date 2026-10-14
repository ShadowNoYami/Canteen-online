import 'package:flutter/material.dart';
import 'main.dart'; 

class InclusiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const InclusiveAppBar({super.key, required this.title, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton 
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))
          : null,
      // Вставляем логотип рядом с названием
      title: Row(
        children: [
          // Загружаем локальный логотип. Если файла нет, покажется стандартная иконка
          Image.asset('assets/logo.png', height: 32, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported)),
          const SizedBox(width: 10),
          Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.volume_up, color: Colors.blue),
          tooltip: 'Озвучить экран',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.record_voice_over, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Озвучиваю содержимое...'),
                  ],
                ),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          },
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}