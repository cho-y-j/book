import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/notification_providers.dart';
import '../../../providers/auth_providers.dart';

class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('알림'), actions: [
        TextButton(onPressed: () {
          final uid = ref.read(currentUserProvider)?.uid;
          if (uid != null) ref.read(notificationRepositoryProvider).markAllAsRead(uid);
        }, child: Text('모두 읽음', style: TextStyle(color: AppColors.primary))),
      ]),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('알림을 불러올 수 없습니다', style: AppTypography.bodyMedium)),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.notifications_none, size: 80, color: AppColors.divider),
              const SizedBox(height: 16),
              Text('알림이 없습니다', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            itemCount: notifications.length,
            itemBuilder: (_, i) {
              final n = notifications[i];
              return ListTile(
                leading: Icon(n.isRead ? Icons.notifications_none : Icons.notifications_active, color: n.isRead ? AppColors.textSecondary : AppColors.primary),
                title: Text(n.title, style: AppTypography.titleMedium.copyWith(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(n.body, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () {
                  if (!n.isRead) ref.read(notificationRepositoryProvider).markAsRead(n.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
