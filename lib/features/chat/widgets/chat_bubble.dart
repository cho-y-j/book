import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class ChatBubble extends StatelessWidget {
  final String text; final bool isMe; final String time;
  const ChatBubble({super.key, required this.text, required this.isMe, required this.time});
  @override
  Widget build(BuildContext context) {
    return Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, child: Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      decoration: BoxDecoration(color: isMe ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
        bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(text, style: AppTypography.bodyMedium.copyWith(color: isMe ? Colors.white : AppColors.textPrimary)),
        const SizedBox(height: 2), Text(time, style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : AppColors.textSecondary)),
      ]),
    ));
  }
}
