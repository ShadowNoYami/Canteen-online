import 'package:flutter/material.dart';
import 'bootstrap_page.dart';

// Глобальная переменная для управления размером шрифта во всем приложении
final ValueNotifier<double> textScaleNotifier = ValueNotifier(1.0);

void main() {
  runApp(const SmartCanteenApp());
}

class SmartCanteenApp extends StatelessWidget {
  const SmartCanteenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: textScaleNotifier,
      builder: (context, scale, child) {
        return MaterialApp(
          title: 'Canteen Online', // Изменено здесь
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.orange,
            scaffoldBackgroundColor: Colors.grey[50],
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                color: Colors.black, 
                fontSize: 20, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          // Оборачиваем все приложение в MediaQuery для изменения масштаба текста
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: widget!,
            );
          },
          // ИСПРАВЛЕНО: Название класса начинается с БОЛЬШОЙ буквы
          home: const BootstrapPage(), 
        );
      },
    );
  }
}