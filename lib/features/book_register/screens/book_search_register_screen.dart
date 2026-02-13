import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class BookSearchRegisterScreen extends ConsumerWidget {
  const BookSearchRegisterScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('책 등록')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('어떤 방법으로 등록할까요?', style: AppTypography.headlineSmall),
          const SizedBox(height: 32),
          _RegisterOptionCard(icon: Icons.qr_code_scanner, title: '바코드 스캔', description: 'ISBN 바코드를 스캔하여\n빠르게 등록', onTap: () => context.push(AppRoutes.barcodeScan)),
          const SizedBox(height: 16),
          _RegisterOptionCard(icon: Icons.search, title: '책 제목 검색', description: '제목이나 저자로\n검색하여 등록', onTap: () => context.push(AppRoutes.manualRegister)),
          const SizedBox(height: 16),
          _RegisterOptionCard(icon: Icons.edit_note, title: '직접 등록', description: 'DB에 없는 책을\n직접 정보 입력', onTap: () => context.push(AppRoutes.manualRegister)),
        ]),
      ),
    );
  }
}

class _RegisterOptionCard extends StatelessWidget {
  final IconData icon; final String title; final String description; final VoidCallback onTap;
  const _RegisterOptionCard({required this.icon, required this.title, required this.description, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppDimensions.radiusMD), child: Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Row(children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.2), borderRadius: BorderRadius.circular(AppDimensions.radiusMD)), child: Icon(icon, color: AppColors.primary, size: 28)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTypography.titleMedium), const SizedBox(height: 4), Text(description, style: AppTypography.bodySmall)])),
        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ]),
    )));
  }
}
