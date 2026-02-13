import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../providers/auth_providers.dart';
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
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    final user = authState.value;

    if (user != null) {
      context.go(AppRoutes.home);
    } else {
      final storage = StorageService();
      await storage.init();
      final hasSeenOnboarding = storage.hasSeenOnboarding;
      if (!mounted) return;
      context.go(hasSeenOnboarding ? AppRoutes.login : AppRoutes.onboarding);
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
            Text('책다리', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 8),
            Text('BookBridge', style: TextStyle(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
