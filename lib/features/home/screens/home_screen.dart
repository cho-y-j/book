import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/constants/enums.dart';
import '../../../providers/book_providers.dart';
import '../widgets/book_feed_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedGenre;
  SortOption _sortOption = SortOption.latest;

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(availableBooksProvider(_selectedGenre));

    return Scaffold(
      appBar: AppBar(
        title: const Text('책다리'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push(AppRoutes.notifications)),
        ],
      ),
      body: Column(children: [
        // Genre filter chips
        SizedBox(height: 48, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
          children: [null, ...BookGenre.values.where((g) => g != BookGenre.all)].map((genre) {
            final isSelected = _selectedGenre == genre?.name;
            return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(
              label: Text(genre?.label ?? '전체'),
              selected: genre == null ? _selectedGenre == null : isSelected,
              selectedColor: AppColors.primaryLight,
              onSelected: (_) => setState(() => _selectedGenre = genre?.name),
            ));
          }).toList(),
        )),
        // Sort options
        Padding(padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD, vertical: 4),
          child: Row(children: [
            Text('${booksAsync.value?.length ?? 0}권', style: AppTypography.bodySmall),
            const Spacer(),
            DropdownButton<SortOption>(
              value: _sortOption, underline: const SizedBox(), isDense: true,
              style: AppTypography.bodySmall,
              items: SortOption.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
              onChanged: (v) { if (v != null) setState(() => _sortOption = v); },
            ),
          ]),
        ),
        // Book list
        Expanded(child: booksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text('불러오기 실패', style: AppTypography.bodyMedium),
            const SizedBox(height: 8),
            TextButton(onPressed: () => ref.invalidate(availableBooksProvider(_selectedGenre)), child: const Text('다시 시도')),
          ])),
          data: (books) {
            if (books.isEmpty) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.menu_book, size: 64, color: AppColors.divider),
                const SizedBox(height: 16),
                Text('등록된 책이 없습니다', style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('첫 번째 책을 등록해보세요!', style: AppTypography.bodySmall),
              ]));
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(availableBooksProvider(_selectedGenre)),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                itemCount: books.length,
                itemBuilder: (_, i) => BookFeedCard(
                  book: books[i],
                  onTap: () => context.push(AppRoutes.bookDetailPath(books[i].id)),
                ),
              ),
            );
          },
        )),
      ]),
    );
  }
}
