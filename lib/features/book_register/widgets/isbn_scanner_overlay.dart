import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class IsbnScannerOverlay extends StatelessWidget {
  const IsbnScannerOverlay({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.accent, width: 2), borderRadius: BorderRadius.circular(12)),
      child: const SizedBox(width: 280, height: 180),
    );
  }
}
