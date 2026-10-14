import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_canteen/main.dart';

void main() {
  testWidgets('SmartCanteenApp smoke test - splash screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartCanteenApp());

    // Проверяем, что отображается название приложения на экране загрузки
    expect(find.text('Canteen Online'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
