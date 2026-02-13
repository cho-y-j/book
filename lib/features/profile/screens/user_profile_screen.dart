import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/book_providers.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userFuture = ref.watch(userRepositoryProvider).getUser(userId);
    final booksAsync = ref.watch(userBooksProvider(userId));

    return Scaffold(
      appBar: AppBar(actions: [IconButton(icon: const Icon(Icons.flag_outlined), onPressed: () {})]),
      body: FutureBuilder(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final user = snapshot.data;
          final nickname = user?.nickname ?? '사용자';
          final location = user?.primaryLocation ?? '지역 미설정';
          final temp = user?.bookTemperature.toStringAsFixed(1) ?? '36.5';
          final exchanges = user?.totalExchanges ?? 0;
          final level = user?.level ?? 1;

          return SingleChildScrollView(child: Column(children: [
            Padding(padding: const EdgeInsets.all(AppDimensions.paddingLG), child: Column(children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: user?.profileImageUrl != null ? NetworkImage(user!.profileImageUrl!) : null,
                child: user?.profileImageUrl == null ? const Icon(Icons.person, size: 40) : null,
              ),
              const SizedBox(height: 12),
              Text(nickname, style: AppTypography.headlineSmall),
              Text(location, style: AppTypography.bodySmall),
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.all(AppDimensions.paddingMD), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Column(children: [Text('$temp°C', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)), const Text('온도', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))]),
                  Column(children: [Text('${exchanges}회', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)), const Text('교환', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))]),
                  Column(children: [Text('Lv.$level', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)), const Text('레벨', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))]),
                ]),
              ),
            ])),
            const Divider(),
            Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('교환 가능한 책', style: AppTypography.titleMedium),
              const SizedBox(height: 12),
              booksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Text('책을 불러올 수 없습니다'),
                data: (books) {
                  if (books.isEmpty) return Text('등록된 책이 없습니다', style: AppTypography.bodySmall);
                  return Column(children: books.take(5).map((book) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
                    leading: Container(width: 45, height: 60, color: AppColors.divider, child: const Icon(Icons.book, size: 20)),
                    title: Text(book.title), subtitle: Text(book.author),
                    onTap: () => context.push(AppRoutes.bookDetailPath(book.id)),
                  ))).toList());
                },
              ),
            ])),
          ]));
        },
      ),
    );
  }
}
