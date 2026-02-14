import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class DeliveryMethodCard extends StatelessWidget {
  final String? selectedMethod;
  final bool isSelectable;
  final void Function(String method)? onSelect;

  const DeliveryMethodCard({
    super.key,
    this.selectedMethod,
    this.isSelectable = true,
    this.onSelect,
  });

  static const _methods = [
    ('courier_request', '택배 요청', Icons.local_shipping, '기관이 택배 수거를 요청합니다'),
    ('cod_shipping', '착불 발송', Icons.inventory_2, '기증자가 착불로 발송합니다'),
    ('in_person', '직접 방문 전달', Icons.directions_walk, '기증자가 직접 방문합니다'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '전달 방법을 선택하세요',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ..._methods.map((m) {
            final (key, label, icon, desc) = m;
            final isSelected = selectedMethod == key;
            final isDisabled = selectedMethod != null && !isSelected;

            if (isDisabled) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: isSelected
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: isSelectable && selectedMethod == null
                      ? () => onSelect?.call(key)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: isSelected ? Colors.blue : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.blue : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                desc,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.blue, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
