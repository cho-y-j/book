import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  const CustomAppBar({super.key, required this.title, this.actions, this.showBack = true});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title, style: AppTypography.titleLarge), backgroundColor: AppColors.surface, elevation: 0, centerTitle: true,
      automaticallyImplyLeading: showBack, actions: actions);
  }
}
