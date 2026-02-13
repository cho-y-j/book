import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../common/widgets/user_avatar.dart';

class ChatListTile extends StatelessWidget {
  final String name; final String? imageUrl; final String lastMessage; final String time; final int unread; final VoidCallback onTap;
  const ChatListTile({super.key, required this.name, this.imageUrl, required this.lastMessage, required this.time, this.unread = 0, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(leading: UserAvatar(imageUrl: imageUrl), title: Text(name, style: AppTypography.titleMedium), subtitle: Text(lastMessage, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(time, style: AppTypography.caption),
        if (unread > 0) ...[const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)), child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11)))],
      ]), onTap: onTap);
  }
}
