import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  const UserAvatar({super.key, this.imageUrl, this.radius = 24});
  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(radius: radius, backgroundImage: CachedNetworkImageProvider(imageUrl!));
    }
    return CircleAvatar(radius: radius, backgroundColor: AppColors.primaryLight.withOpacity(0.3), child: Icon(Icons.person, size: radius, color: AppColors.primary));
  }
}
