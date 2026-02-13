import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class RecentSearchList extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onDelete;
  final VoidCallback onClearAll;
  const RecentSearchList({super.key, required this.searches, required this.onTap, required this.onDelete, required this.onClearAll});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('최근 검색어', style: AppTypography.titleMedium),
        TextButton(onPressed: onClearAll, child: Text('전체 삭제', style: TextStyle(color: AppColors.textSecondary))),
      ])),
      ...searches.map((s) => ListTile(leading: const Icon(Icons.history, color: AppColors.textSecondary), title: Text(s),
        trailing: IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => onDelete(s)), onTap: () => onTap(s))),
    ]);
  }
}
