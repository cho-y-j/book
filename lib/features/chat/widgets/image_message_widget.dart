import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';

class ImageMessageWidget extends StatelessWidget {
  final String? imageUrl; final bool isMe;
  const ImageMessageWidget({super.key, this.imageUrl, required this.isMe});
  @override
  Widget build(BuildContext context) {
    return Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, child: Container(
      margin: const EdgeInsets.only(bottom: 8), width: 200, height: 200,
      decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
      child: const Center(child: Icon(Icons.image, size: 48, color: AppColors.textSecondary)),
    ));
  }
}
