import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/enums.dart';

class ConditionSelector extends StatelessWidget {
  final BookCondition selected;
  final ValueChanged<BookCondition> onChanged;
  const ConditionSelector({super.key, required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, children: BookCondition.values.map((c) => ChoiceChip(label: Text(c.label), selected: selected == c, selectedColor: AppColors.primaryLight, onSelected: (_) => onChanged(c))).toList());
  }
}
