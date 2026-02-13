import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class MatchAnimationWidget extends StatelessWidget {
  const MatchAnimationWidget({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: Replace with Lottie animation
    return const Center(child: Icon(Icons.celebration, size: 120, color: AppColors.accent));
  }
}
