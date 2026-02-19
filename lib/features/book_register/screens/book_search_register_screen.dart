import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../data/datasources/remote/book_api_datasource.dart';

class BookSearchRegisterScreen extends ConsumerWidget {
  const BookSearchRegisterScreen({super.key});

  Future<void> _handleBarcodeScan(BuildContext context) async {
    final isbn = await context.push<String>(AppRoutes.barcodeScan);
    if (isbn == null || isbn.isEmpty) return;
    if (!context.mounted) return;

    // 로딩 다이얼로그
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final datasource = BookApiDatasource();
      final bookData = await datasource.searchByIsbn(isbn);

      if (!context.mounted) return;
      Navigator.pop(context); // 로딩 닫기

      if (bookData != null) {
        context.push(AppRoutes.bookCondition, extra: bookData);
      } else {
        _showNotFoundDialog(context, isbn);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // 로딩 닫기
      _showNotFoundDialog(context, isbn, error: '$e');
    }
  }

  void _showNotFoundDialog(BuildContext context, String isbn, {String? error}) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        icon: const Icon(Icons.search_off, size: 48, color: Colors.orange),
        title: const Text('책을 찾을 수 없습니다'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            error != null
                ? '조회 중 오류가 발생했습니다.\nISBN: $isbn'
                : 'ISBN $isbn에 해당하는 책이\n데이터베이스에 없습니다.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            '직접 등록하시면 다른 사용자도 이 책을 찾을 수 있어요!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('닫기'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dCtx);
              context.push(AppRoutes.manualRegister);
            },
            icon: const Icon(Icons.edit_note, size: 18),
            label: const Text('직접 등록'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('책 등록')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('어떤 방법으로 등록할까요?', style: AppTypography.headlineSmall),
          const SizedBox(height: 32),
          _RegisterOptionCard(icon: Icons.qr_code_scanner, title: '바코드 스캔', description: 'ISBN 바코드를 스캔하여\n빠르게 등록', onTap: () => _handleBarcodeScan(context)),
          const SizedBox(height: 16),
          _RegisterOptionCard(icon: Icons.search, title: '책 제목 검색', description: '제목이나 저자로\n검색하여 등록', onTap: () => context.push(AppRoutes.bookTitleSearch)),
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
