import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onKakao;
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  const SocialLoginButtons({super.key, required this.onKakao, required this.onGoogle, required this.onApple});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _SocialButton(icon: Icons.chat_bubble, label: '카카오로 시작하기', color: const Color(0xFFFEE500), textColor: Colors.black87, onPressed: onKakao),
      const SizedBox(height: 12),
      _SocialButton(icon: Icons.g_mobiledata, label: 'Google로 시작하기', color: Colors.white, textColor: Colors.black87, onPressed: onGoogle),
      const SizedBox(height: 12),
      _SocialButton(icon: Icons.apple, label: 'Apple로 시작하기', color: Colors.black, textColor: Colors.white, onPressed: onApple),
    ]);
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon; final String label; final Color color; final Color textColor; final VoidCallback onPressed;
  const _SocialButton({required this.icon, required this.label, required this.color, required this.textColor, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(onPressed: onPressed, icon: Icon(icon, color: textColor), label: Text(label, style: TextStyle(color: textColor)),
      style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD), side: BorderSide(color: AppColors.divider)))));
  }
}
