import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:book_bridge/app/theme/app_colors.dart';
import 'package:book_bridge/app/theme/app_theme.dart';

void main() {
  testWidgets('BookBridge theme smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(child: Text('책다리')),
        ),
      ),
    );

    expect(find.text('책다리'), findsOneWidget);
  });

  test('AppColors are correctly defined', () {
    expect(AppColors.primary, const Color(0xFF8B6914));
    expect(AppColors.secondary, const Color(0xFF4A7C59));
    expect(AppColors.accent, const Color(0xFFE8734A));
    expect(AppColors.background, const Color(0xFFF5F0E8));
  });
}
