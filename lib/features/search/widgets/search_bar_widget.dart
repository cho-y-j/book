import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  const SearchBarWidget({super.key, required this.controller, this.onSubmitted, this.onFilterTap});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: TextField(
      controller: controller, decoration: InputDecoration(hintText: '책 제목, 저자로 검색', prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(icon: const Icon(Icons.tune), onPressed: onFilterTap),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD), borderSide: const BorderSide(color: AppColors.divider))),
      onSubmitted: onSubmitted,
    ));
  }
}
