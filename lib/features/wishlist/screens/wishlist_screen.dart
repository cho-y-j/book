import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';


class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('위시리스트')),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.bookmark_outline, size: 80, color: AppColors.divider),
        const SizedBox(height: 16),
        Text('위시리스트가 비어있어요', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text('관심있는 책을 위시리스트에 추가해보세요', style: AppTypography.bodySmall),
      ])),
      floatingActionButton: FloatingActionButton(onPressed: () {}, backgroundColor: AppColors.primary, child: const Icon(Icons.add, color: Colors.white)),
    );
  }
}
