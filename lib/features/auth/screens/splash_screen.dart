import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/storage_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    // 최소 스플래시 표시 시간 + Firebase Auth 초기화 대기를 병렬 실행
    final minDelay = Future.delayed(const Duration(milliseconds: 1500));

    // Firebase Auth의 첫 번째 authStateChanges 이벤트를 기다림
    // 이 이벤트가 와야 로그인 상태를 정확히 알 수 있음
    final authUser = await FirebaseAuth.instance.authStateChanges().first;

    await minDelay; // 최소 스플래시 시간 보장
    if (!mounted) return;

    final storage = StorageService();
    await storage.init();
    if (!mounted) return;

    if (authUser != null && storage.autoLogin) {
      // 자동 로그인 ON + 기존 세션 존재 → 홈으로
      context.go(AppRoutes.home);
    } else {
      // 자동 로그인 OFF이거나 세션 없음
      if (authUser != null && !storage.autoLogin) {
        // 자동 로그인 OFF인데 세션이 남아있으면 로그아웃 처리
        await FirebaseAuth.instance.signOut();
      }
      context.go(storage.hasSeenOnboarding ? AppRoutes.login : AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.menu_book_rounded, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text('책가지', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 8),
            Text('BookGaji', style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 32),
            SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
