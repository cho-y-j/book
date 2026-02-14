import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../data/models/review_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/review_providers.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final String matchId;
  const WriteReviewScreen({super.key, required this.matchId});
  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  double _rating = 4.0;
  double _conditionAccuracy = 4.0;
  double _responseSpeed = 4.0;
  double _manner = 4.0;
  final _commentController = TextEditingController();
  final _selectedTags = <String>{};
  final _availableTags = ['빠른 응답', '상태 정확', '친절', '시간 약속 잘 지킴', '포장 꼼꼼'];
  bool _isSaving = false;

  @override
  void dispose() { _commentController.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);
    try {
      final review = ReviewModel(
        id: '',
        matchId: widget.matchId,
        reviewerUid: uid,
        revieweeUid: '', // TODO: 매치에서 상대방 UID 가져오기
        rating: _rating,
        bookConditionAccuracy: _conditionAccuracy,
        responseSpeed: _responseSpeed,
        manner: _manner,
        comment: _commentController.text.trim().isNotEmpty ? _commentController.text.trim() : null,
        tags: _selectedTags.toList(),
        createdAt: DateTime.now(),
      );

      await ref.read(reviewRepositoryProvider).createReview(review);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('후기가 등록되었어요!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('후기 등록 실패: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('후기 작성')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('교환은 어떠셨나요?', style: AppTypography.headlineSmall),
          const SizedBox(height: 24),
          _RatingRow(label: '전체 평점', value: _rating, onChanged: (v) => setState(() => _rating = v)),
          _RatingRow(label: '책 상태 정확도', value: _conditionAccuracy, onChanged: (v) => setState(() => _conditionAccuracy = v)),
          _RatingRow(label: '응답 속도', value: _responseSpeed, onChanged: (v) => setState(() => _responseSpeed = v)),
          _RatingRow(label: '매너', value: _manner, onChanged: (v) => setState(() => _manner = v)),
          const SizedBox(height: 24),
          Text('태그 선택', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _availableTags.map((tag) => FilterChip(
            label: Text(tag),
            selected: _selectedTags.contains(tag),
            selectedColor: AppColors.primaryLight,
            onSelected: (selected) => setState(() { selected ? _selectedTags.add(tag) : _selectedTags.remove(tag); }),
          )).toList()),
          const SizedBox(height: 24),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: '한줄 후기 (선택)', hintText: '교환 경험을 공유해주세요'),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('후기 등록'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String label; final double value; final ValueChanged<double> onChanged;
  const _RatingRow({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        SizedBox(width: 100, child: Text(label, style: AppTypography.bodyMedium)),
        Expanded(child: Slider(value: value, min: 1, max: 5, divisions: 8, activeColor: AppColors.primary, onChanged: onChanged)),
        SizedBox(width: 30, child: Text(value.toStringAsFixed(1), style: AppTypography.labelLarge)),
      ]),
    );
  }
}
