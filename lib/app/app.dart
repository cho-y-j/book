import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';

class BookGajiApp extends ConsumerWidget {
  const BookGajiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 글로벌 에러 위젯: 검은 화면 대신 친절한 에러 메시지 표시
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, size: 64, color: AppColors.warning),
                const SizedBox(height: 16),
                const Text(
                  '화면을 불러올 수 없습니다',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '뒤로 가기를 눌러주세요',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    };

    return MaterialApp.router(
      title: '책가지',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      builder: (context, child) {
        // 앱 전체 에러 바운더리
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
