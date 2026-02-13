import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class ReviewTagSelector extends StatelessWidget {
  final Set<String> selectedTags; final ValueChanged<String> onToggle;
  static const tags = ['빠른 응답', '상태 정확', '친절', '시간 약속 잘 지킴', '포장 꼼꼼'];
  const ReviewTagSelector({super.key, required this.selectedTags, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: tags.map((t) => FilterChip(label: Text(t), selected: selectedTags.contains(t), selectedColor: AppColors.primaryLight, onSelected: (_) => onToggle(t))).toList());
  }
}
