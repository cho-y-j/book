import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/review_providers.dart';

class ReceivedReviewsScreen extends ConsumerWidget {
  const ReceivedReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider)?.uid;
    if (uid == null) {
      return Scaffold(appBar: AppBar(title: const Text('받은 후기')), body: const Center(child: Text('로그인이 필요합니다')));
    }

    final reviewsAsync = ref.watch(receivedReviewsProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text('받은 후기')),
      body: reviewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
        data: (reviews) {
          if (reviews.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.star_outline, size: 80, color: AppColors.divider),
                const SizedBox(height: 16),
                Text('아직 받은 후기가 없어요', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('교환을 완료하면 후기를 받을 수 있어요', style: AppTypography.bodySmall),
              ]),
            );
          }

          // 평균 평점 계산
          final avgRating = reviews.fold<double>(0, (sum, r) => sum + r.rating) / reviews.length;

          return ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            children: [
              // 평균 평점 카드
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  child: Column(children: [
                    Text('평균 평점', style: AppTypography.bodySmall),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.star, color: AppColors.warning, size: 32),
                      const SizedBox(width: 8),
                      Text(avgRating.toStringAsFixed(1), style: AppTypography.headlineSmall.copyWith(color: AppColors.warning)),
                      Text(' / 5.0', style: AppTypography.bodySmall),
                    ]),
                    const SizedBox(height: 4),
                    Text('총 ${reviews.length}개의 후기', style: AppTypography.caption),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // 후기 목록
              ...reviews.map((review) {
                final timeAgo = _timeAgo(review.createdAt);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        // 별점
                        ...List.generate(5, (i) => Icon(
                          i < review.rating.round() ? Icons.star : Icons.star_border,
                          color: AppColors.warning, size: 18,
                        )),
                        const SizedBox(width: 8),
                        Text(review.rating.toStringAsFixed(1), style: AppTypography.labelLarge),
                        const Spacer(),
                        Text(timeAgo, style: AppTypography.caption),
                      ]),
                      if (review.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6, runSpacing: 4,
                          children: review.tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(tag, style: AppTypography.caption.copyWith(color: AppColors.primary)),
                          )).toList(),
                        ),
                      ],
                      if (review.comment != null && review.comment!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(review.comment!, style: AppTypography.bodyMedium),
                      ],
                      const SizedBox(height: 8),
                      Row(children: [
                        _MiniRating(label: '상태정확', value: review.bookConditionAccuracy),
                        const SizedBox(width: 12),
                        _MiniRating(label: '응답속도', value: review.responseSpeed),
                        const SizedBox(width: 12),
                        _MiniRating(label: '매너', value: review.manner),
                      ]),
                    ]),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}달 전';
    if (diff.inDays > 0) return '${diff.inDays}일 전';
    if (diff.inHours > 0) return '${diff.inHours}시간 전';
    return '방금 전';
  }
}

class _MiniRating extends StatelessWidget {
  final String label;
  final double value;
  const _MiniRating({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text('$label ', style: AppTypography.caption),
      Icon(Icons.star, size: 12, color: AppColors.warning),
      Text(value.toStringAsFixed(1), style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
    ]);
  }
}
