import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/ranking_providers.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('랭킹'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [Tab(text: '교환왕'), Tab(text: '인기 책'), Tab(text: '조회수')],
          ),
        ),
        body: TabBarView(children: [
          _ExchangeRankTab(ref: ref),
          _PopularBooksTab(ref: ref),
          _MostViewedTab(ref: ref),
        ]),
      ),
    );
  }
}

class _ExchangeRankTab extends StatelessWidget {
  final WidgetRef ref;
  const _ExchangeRankTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(topExchangersProvider);
    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
      data: (users) {
        if (users.isEmpty) {
          return Center(child: Text('아직 교환 데이터가 없어요', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          itemCount: users.length,
          itemBuilder: (_, i) {
            final user = users[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: i < 3 ? AppColors.primaryLight : AppColors.divider,
                backgroundImage: user.profileImageUrl != null ? CachedNetworkImageProvider(user.profileImageUrl!) : null,
                child: user.profileImageUrl == null
                    ? Text('${i + 1}', style: TextStyle(color: i < 3 ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold))
                    : null,
              ),
              title: Text(user.nickname.isNotEmpty ? user.nickname : '사용자', style: AppTypography.titleMedium),
              subtitle: Text('${user.totalExchanges}회 교환 · Lv.${user.level}', style: AppTypography.caption),
              trailing: i == 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Text('1위', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  : Text('#${i + 1}', style: AppTypography.caption),
            );
          },
        );
      },
    );
  }
}

class _PopularBooksTab extends StatelessWidget {
  final WidgetRef ref;
  const _PopularBooksTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(popularBooksProvider);
    return booksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
      data: (books) {
        if (books.isEmpty) {
          return Center(child: Text('아직 데이터가 없어요', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          itemCount: books.length,
          itemBuilder: (_, i) {
            final book = books[i];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 45, height: 60,
                  child: book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty
                      ? CachedNetworkImage(imageUrl: book.coverImageUrl!, fit: BoxFit.cover)
                      : Container(color: AppColors.divider, child: Center(child: Text('${i + 1}', style: AppTypography.labelLarge))),
                ),
              ),
              title: Text(book.title, style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${book.author} · 찜 ${book.wishCount}회', style: AppTypography.caption),
            );
          },
        );
      },
    );
  }
}

class _MostViewedTab extends StatelessWidget {
  final WidgetRef ref;
  const _MostViewedTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(mostViewedBooksProvider);
    return booksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
      data: (books) {
        if (books.isEmpty) {
          return Center(child: Text('아직 데이터가 없어요', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          itemCount: books.length,
          itemBuilder: (_, i) {
            final book = books[i];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 45, height: 60,
                  child: book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty
                      ? CachedNetworkImage(imageUrl: book.coverImageUrl!, fit: BoxFit.cover)
                      : Container(color: AppColors.divider, child: Center(child: Text('${i + 1}', style: AppTypography.labelLarge))),
                ),
              ),
              title: Text(book.title, style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${book.author} · 조회 ${book.viewCount}회', style: AppTypography.caption),
            );
          },
        );
      },
    );
  }
}
