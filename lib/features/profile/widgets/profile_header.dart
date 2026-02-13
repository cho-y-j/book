import 'package:flutter/material.dart';
import '../../../app/theme/app_typography.dart';
import '../../common/widgets/user_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final String nickname; final String location; final String? imageUrl;
  const ProfileHeader({super.key, required this.nickname, required this.location, this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Column(children: [UserAvatar(imageUrl: imageUrl, radius: 40), const SizedBox(height: 12), Text(nickname, style: AppTypography.headlineSmall), const SizedBox(height: 4), Text(location, style: AppTypography.bodySmall)]);
  }
}
