import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/notification_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../data/models/notification_model.dart';

class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  IconData _iconForType(String type) {
    switch (type) {
      case 'wishlist_match':
        return Icons.auto_awesome;
      case 'exchange_request':
      case 'match':
        return Icons.swap_horiz;
      case 'chat':
        return Icons.chat_bubble;
      case 'purchase':
        return Icons.shopping_cart;
      case 'sharing':
        return Icons.volunteer_activism;
      default:
        return Icons.notifications;
    }
  }

  void _onNotificationTap(BuildContext context, WidgetRef ref, NotificationModel n) {
    if (!n.isRead) {
      ref.read(notificationRepositoryProvider).markAsRead(n.id);
    }

    final data = n.data;
    final type = data?['type'] as String? ?? n.type;
    final id = data?['id'] as String?;

    if (id == null || id.isEmpty) return;

    switch (type) {
      case 'wishlist_match':
        context.push(AppRoutes.bookDetailPath(id));
        break;
      case 'exchange_request':
      case 'match':
        context.push(AppRoutes.incomingRequests);
        break;
      case 'chat':
        context.push(AppRoutes.chatRoomPath(id));
        break;
      default:
        break;
    }
  }

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
              final hasLink = n.data?['id'] != null;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: n.isRead ? AppColors.divider : AppColors.primaryLight,
                  child: Icon(
                    _iconForType(n.type),
                    color: n.isRead ? AppColors.textSecondary : AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(n.title, style: AppTypography.titleMedium.copyWith(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(n.body, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: hasLink ? Icon(Icons.chevron_right, color: AppColors.textSecondary) : null,
                onTap: () => _onNotificationTap(context, ref, n),
              );
            },
          );
        },
      ),
    );
  }
}
