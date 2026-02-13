import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/auth_providers.dart';

/// Provider to fetch the book owner's profile by UID.
final _bookOwnerProvider = FutureProvider.family<UserModel?, String>(
  (ref, ownerUid) async {
    return ref.watch(userRepositoryProvider).getUser(ownerUid);
  },
);

/// Provider to track local wishlist toggle state per book.
/// In a full implementation this would persist to Firestore; here we keep it
/// in-memory so the heart icon is responsive.
final _wishlistToggleProvider =
    StateProvider.family<bool, String>((ref, bookId) => false);

class BookDetailScreen extends ConsumerWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  String _exchangeTypeLabel(String type) {
    switch (type) {
      case 'local_only':
        return '직거래만';
      case 'delivery_only':
        return '택배만';
      case 'both':
        return '직거래 + 택배';
      default:
        return type;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'available':
        return '교환가능';
      case 'reserved':
        return '예약중';
      case 'exchanged':
        return '교환완료';
      case 'hidden':
        return '숨김';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.success;
      case 'reserved':
        return AppColors.warning;
      case 'exchanged':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookDetailProvider(bookId));
    final currentUser = ref.watch(currentUserProvider);
    final isWishlisted = ref.watch(_wishlistToggleProvider(bookId));

    return bookAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              Text(
                '책 정보를 불러올 수 없습니다',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              TextButton(
                onPressed: () => ref.invalidate(bookDetailProvider(bookId)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
      data: (book) {
        if (book == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(
                '존재하지 않는 책입니다',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        final isOwner = currentUser?.uid == book.ownerUid;
        final ownerAsync = ref.watch(_bookOwnerProvider(book.ownerUid));

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? AppColors.error : null,
                ),
                onPressed: () {
                  ref.read(_wishlistToggleProvider(bookId).notifier).state =
                      !isWishlisted;
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: implement share
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Cover image ---
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    image: book.coverImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(book.coverImageUrl!),
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: book.coverImageUrl == null
                      ? const Icon(
                          Icons.book,
                          size: 80,
                          color: AppColors.textSecondary,
                        )
                      : null,
                ),

                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Status badge ---
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(book.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSM,
                          ),
                        ),
                        child: Text(
                          _statusLabel(book.status),
                          style: AppTypography.caption.copyWith(
                            color: _statusColor(book.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSM),

                      // --- Title & Author ---
                      Text(book.title, style: AppTypography.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSM),

                      // --- Stats row ---
                      Row(
                        children: [
                          _StatChip(
                            icon: Icons.visibility_outlined,
                            label: '조회 ${book.viewCount}',
                          ),
                          const SizedBox(width: AppDimensions.paddingSM),
                          _StatChip(
                            icon: Icons.favorite_outline,
                            label: '관심 ${book.wishCount}',
                          ),
                          const SizedBox(width: AppDimensions.paddingSM),
                          _StatChip(
                            icon: Icons.swap_horiz,
                            label: '요청 ${book.requestCount}',
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.paddingMD),
                      const Divider(),
                      const SizedBox(height: AppDimensions.paddingMD),

                      // --- Book info rows ---
                      _InfoRow(
                        label: '상태',
                        value: Formatters.bookConditionLabel(book.condition),
                      ),
                      _InfoRow(
                        label: '거래 방식',
                        value: _exchangeTypeLabel(book.exchangeType),
                      ),
                      _InfoRow(label: '지역', value: book.location),
                      _InfoRow(label: '장르', value: book.genre),
                      if (book.conditionNote != null &&
                          book.conditionNote!.isNotEmpty)
                        _InfoRow(label: '상태 메모', value: book.conditionNote!),
                      _InfoRow(
                        label: '등록일',
                        value: Formatters.timeAgo(book.createdAt),
                      ),

                      // --- Tags ---
                      if (book.tags.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.paddingSM),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: book.tags
                              .map(
                                (tag) => Chip(
                                  label: Text(
                                    '#$tag',
                                    style: AppTypography.caption,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: AppColors.background,
                                  side: BorderSide.none,
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      // --- Condition photos ---
                      if (book.conditionPhotos.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.paddingMD),
                        Text('상태 사진', style: AppTypography.titleMedium),
                        const SizedBox(height: AppDimensions.paddingSM),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: book.conditionPhotos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: AppDimensions.paddingSM),
                            itemBuilder: (_, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSM,
                              ),
                              child: Image.network(
                                book.conditionPhotos[i],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 120,
                                  height: 120,
                                  color: AppColors.divider,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: AppDimensions.paddingMD),
                      const Divider(),
                      const SizedBox(height: AppDimensions.paddingMD),

                      // --- Owner info ---
                      Text('소유자 정보', style: AppTypography.titleMedium),
                      const SizedBox(height: AppDimensions.paddingSM),
                      ownerAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        error: (_, __) => Text(
                          '소유자 정보를 불러올 수 없습니다',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        data: (owner) {
                          if (owner == null) {
                            return Text(
                              '탈퇴한 사용자',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            );
                          }
                          return InkWell(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMD,
                            ),
                            onTap: () => context.push(
                              AppRoutes.userProfilePath(owner.uid),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage:
                                        owner.profileImageUrl != null
                                            ? NetworkImage(
                                                owner.profileImageUrl!,
                                              )
                                            : null,
                                    child: owner.profileImageUrl == null
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          owner.nickname,
                                          style: AppTypography.titleMedium,
                                        ),
                                        Text(
                                          '${Formatters.temperature(owner.bookTemperature)} · ${owner.primaryLocation}',
                                          style: AppTypography.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: book.status == 'available' && !isOwner
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMD),
                    child: ElevatedButton(
                      onPressed: () => context.push(
                        AppRoutes.exchangeRequestPath(book.id),
                      ),
                      child: const Text('교환 요청하기'),
                    ),
                  ),
                )
              : isOwner
                  ? SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingMD),
                        child: OutlinedButton(
                          onPressed: () => context.push(
                            AppRoutes.bookEditPath(book.id),
                          ),
                          child: const Text('내 책 수정하기'),
                        ),
                      ),
                    )
                  : null,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private helper widgets
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTypography.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 2),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
