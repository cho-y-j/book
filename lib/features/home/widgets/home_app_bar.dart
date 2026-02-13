import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String location;
  final int notificationCount;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;
  const HomeAppBar({super.key, required this.location, this.notificationCount = 0, required this.onLocationTap, required this.onNotificationTap});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GestureDetector(onTap: onLocationTap, child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.menu_book_rounded, color: AppColors.primary),
        const SizedBox(width: 8), Text(location, style: AppTypography.titleMedium),
        const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
      ])),
      actions: [
        Stack(children: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: onNotificationTap),
          if (notificationCount > 0) Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle), child: Text('$notificationCount', style: const TextStyle(color: Colors.white, fontSize: 10)))),
        ]),
      ],
    );
  }
}
