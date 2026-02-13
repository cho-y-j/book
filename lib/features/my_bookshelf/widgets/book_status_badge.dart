import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class BookStatusBadge extends StatelessWidget {
  final String status;
  const BookStatusBadge({super.key, required this.status});
  Color get _color { switch (status) { case 'available': return AppColors.success; case 'reserved': return AppColors.warning; case 'exchanged': return AppColors.info; default: return AppColors.textSecondary; } }
  String get _label { switch (status) { case 'available': return '교환가능'; case 'reserved': return '예약중'; case 'exchanged': return '교환완료'; case 'hidden': return '숨김'; default: return status; } }
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(_label, style: AppTypography.caption.copyWith(color: _color)));
  }
}
