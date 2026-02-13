import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class BookshelfGrid extends StatelessWidget {
  final int itemCount;
  const BookshelfGrid({super.key, this.itemCount = 6});
  @override
  Widget build(BuildContext context) {
    return GridView.builder(padding: const EdgeInsets.all(AppDimensions.paddingMD), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.65, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: itemCount, itemBuilder: (_, i) => Card(child: Column(children: [
        Expanded(child: Container(decoration: BoxDecoration(color: AppColors.divider, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: const Center(child: Icon(Icons.book, color: AppColors.textSecondary)))),
        Padding(padding: const EdgeInsets.all(6), child: Text('책 ${i + 1}', style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ])));
  }
}
