import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/constants/enums.dart';

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({super.key});
  static Future<void> show(BuildContext context) => showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (_) => const SearchFilterSheet());
  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  BookGenre _genre = BookGenre.all;
  ExchangeType _exchangeType = ExchangeType.both;
  BookCondition _condition = BookCondition.good;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(initialChildSize: 0.7, maxChildSize: 0.9, minChildSize: 0.5, expand: false, builder: (_, controller) => Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG), child: ListView(controller: controller, children: [
        Text('필터', style: AppTypography.headlineSmall), const SizedBox(height: 24),
        Text('장르', style: AppTypography.titleMedium), const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: BookGenre.values.map((g) => ChoiceChip(label: Text(g.label), selected: _genre == g, selectedColor: AppColors.primaryLight, onSelected: (_) => setState(() => _genre = g))).toList()),
        const SizedBox(height: 24),
        Text('거래 방식', style: AppTypography.titleMedium), const SizedBox(height: 8),
        Wrap(spacing: 8, children: ExchangeType.values.map((t) => ChoiceChip(label: Text(t.label), selected: _exchangeType == t, selectedColor: AppColors.primaryLight, onSelected: (_) => setState(() => _exchangeType = t))).toList()),
        const SizedBox(height: 24),
        Text('책 상태', style: AppTypography.titleMedium), const SizedBox(height: 8),
        Wrap(spacing: 8, children: BookCondition.values.map((c) => ChoiceChip(label: Text(c.label), selected: _condition == c, selectedColor: AppColors.primaryLight, onSelected: (_) => setState(() => _condition = c))).toList()),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('적용하기')),
      ]),
    ));
  }
}
