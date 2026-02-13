import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class GenreChip extends StatelessWidget {
  final String genre;
  final bool selected;
  final VoidCallback? onTap;
  const GenreChip({super.key, required this.genre, this.selected = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: selected ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: selected ? AppColors.primary : AppColors.divider)),
      child: Text(genre, style: TextStyle(fontSize: 13, color: selected ? Colors.white : AppColors.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
    ));
  }
}
