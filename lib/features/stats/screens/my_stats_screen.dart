import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/auth_providers.dart';

class MyStatsScreen extends ConsumerWidget {
  const MyStatsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final uid = ref.watch(currentUserProvider)?.uid;
    final booksAsync = uid != null ? ref.watch(userBooksProvider(uid)) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('나의 통계')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
        data: (user) {
          final exchanges = user?.totalExchanges ?? 0;
          final paperSaved = (exchanges * 0.2).toStringAsFixed(1);
          final co2Saved = (exchanges * 1.2).toStringAsFixed(1);
          final treesSaved = (exchanges * 0.025).toStringAsFixed(2);

          // 장르 분포 계산
          final genreMap = <String, int>{};
          final books = booksAsync?.value ?? [];
          for (final book in books) {
            final genre = book.genre.isNotEmpty ? book.genre : '기타';
            genreMap[genre] = (genreMap[genre] ?? 0) + 1;
          }
          // 정렬 (많은 순)
          final sortedGenres = genreMap.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final totalBooks = books.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // 환경 기여
              Text('환경 기여', style: AppTypography.headlineSmall),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _StatCard(icon: Icons.eco, label: '종이 절약', value: '${paperSaved}kg', color: AppColors.secondary)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.cloud, label: 'CO₂ 절감', value: '${co2Saved}kg', color: AppColors.info)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _StatCard(icon: Icons.swap_horiz, label: '총 교환', value: '${exchanges}권', color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.forest, label: '나무 보호', value: '${treesSaved}그루', color: AppColors.secondary)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _StatCard(icon: Icons.menu_book, label: '등록한 책', value: '${totalBooks}권', color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.emoji_events, label: '레벨', value: 'Lv.${user?.level ?? 1}', color: AppColors.warning)),
              ]),
              const SizedBox(height: 32),

              // 장르별 분포
              Text('장르별 등록 분포', style: AppTypography.titleMedium),
              const SizedBox(height: 16),
              if (sortedGenres.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text('아직 등록한 책이 없어요', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ),
                )
              else
                ...sortedGenres.map((entry) {
                  final ratio = totalBooks > 0 ? entry.value / totalBooks : 0.0;
                  return _GenreBar(genre: entry.key, ratio: ratio, count: entry.value);
                }),
            ]),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label; final String value; final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Column(children: [
      Icon(icon, color: color, size: 32), const SizedBox(height: 8),
      Text(value, style: AppTypography.titleLarge.copyWith(color: color)),
      Text(label, style: AppTypography.caption),
    ])));
  }
}

class _GenreBar extends StatelessWidget {
  final String genre;
  final double ratio;
  final int count;
  const _GenreBar({required this.genre, required this.ratio, required this.count});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 70, child: Text(genre, style: AppTypography.bodySmall, overflow: TextOverflow.ellipsis)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 55,
          child: Text('${count}권 ${(ratio * 100).toInt()}%', style: AppTypography.caption, textAlign: TextAlign.end),
        ),
      ]),
    );
  }
}
