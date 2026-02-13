import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.shelves,
      title: '내 책장에 등록해요',
      description: '집에 잠자는 책을 등록하고\n새로운 주인을 찾아주세요',
    ),
    _OnboardingPage(
      icon: Icons.search,
      title: '원하는 책을 찾아요',
      description: '읽고 싶었던 책을 검색하고\n주변에서 교환할 책을 발견하세요',
    ),
    _OnboardingPage(
      icon: Icons.swap_horiz_rounded,
      title: '책으로 연결되는 다리',
      description: '돈 대신 책과 책을 교환하며\n새로운 독서 경험을 만들어요',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (_, index) => _pages[index],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_currentPage == _pages.length - 1) {
                          final s = StorageService(); await s.init();
                          await s.setHasSeenOnboarding(true);
                          if (context.mounted) context.go(AppRoutes.login);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _pages.length - 1 ? '시작하기' : '다음',
                      ),
                    ),
                  ),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: () async {
                        final s = StorageService(); await s.init();
                        await s.setHasSeenOnboarding(true);
                        if (context.mounted) context.go(AppRoutes.login);
                      },
                      child: Text('건너뛰기', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: AppColors.primary),
          const SizedBox(height: 40),
          Text(title, style: AppTypography.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(description, style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
