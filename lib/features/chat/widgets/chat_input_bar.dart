import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller; final VoidCallback onSend; final VoidCallback onAttach;
  const ChatInputBar({super.key, required this.controller, required this.onSend, required this.onAttach});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))]),
      child: SafeArea(child: Row(children: [
        IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.textSecondary), onPressed: onAttach),
        Expanded(child: TextField(controller: controller, decoration: InputDecoration(hintText: '메시지 입력', border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), filled: true, fillColor: AppColors.background, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)))),
        const SizedBox(width: 8),
        CircleAvatar(backgroundColor: AppColors.primary, child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: onSend)),
      ])));
  }
}
