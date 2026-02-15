import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/wishlist_model.dart';
import '../../../providers/wishlist_providers.dart';

class BookAlertDialog extends ConsumerStatefulWidget {
  final WishlistModel wishlist;
  const BookAlertDialog({super.key, required this.wishlist});

  @override
  ConsumerState<BookAlertDialog> createState() => _BookAlertDialogState();
}

class _BookAlertDialogState extends ConsumerState<BookAlertDialog> {
  late bool _alertEnabled;
  late Set<String> _conditions;
  late Set<String> _listingTypes;
  bool _saving = false;

  static const _conditionLabels = {
    'best': '최상',
    'good': '상',
    'fair': '중',
    'poor': '하',
  };

  static const _listingTypeLabels = {
    'exchange': '교환',
    'sale': '판매',
    'both': '교환+판매',
  };

  @override
  void initState() {
    super.initState();
    _alertEnabled = widget.wishlist.alertEnabled;
    _conditions = widget.wishlist.preferredConditions.isNotEmpty
        ? widget.wishlist.preferredConditions.toSet()
        : {'best', 'good', 'fair'}; // 기본: 중 이상
    _listingTypes = widget.wishlist.preferredListingTypes.isNotEmpty
        ? widget.wishlist.preferredListingTypes.toSet()
        : {'exchange', 'sale', 'both'}; // 기본: 전체
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(wishlistRepositoryProvider).updateAlertSettings(
        widget.wishlist.id,
        alertEnabled: _alertEnabled,
        preferredConditions: _conditions.toList(),
        preferredListingTypes: _listingTypes.toList(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.notifications_active, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '책 알림 설정',
                  style: AppTypography.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.wishlist.title,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // 알림 ON/OFF
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('이 책이 등록되면 알려주기'),
            subtitle: const Text('조건에 맞는 책이 올라오면 푸시 알림을 보내드려요'),
            value: _alertEnabled,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _alertEnabled = v),
          ),

          if (_alertEnabled) ...[
            const Divider(),
            const SizedBox(height: 8),

            // 상태 조건
            Text('책 상태', style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _conditionLabels.entries.map((e) {
                final selected = _conditions.contains(e.key);
                return FilterChip(
                  label: Text(e.value),
                  selected: selected,
                  selectedColor: AppColors.primaryLight.withOpacity(0.3),
                  checkmarkColor: AppColors.primaryDark,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _conditions.add(e.key);
                      } else if (_conditions.length > 1) {
                        _conditions.remove(e.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 거래 유형
            Text('거래 유형', style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _listingTypeLabels.entries.map((e) {
                final selected = _listingTypes.contains(e.key);
                return FilterChip(
                  label: Text(e.value),
                  selected: selected,
                  selectedColor: AppColors.primaryLight.withOpacity(0.3),
                  checkmarkColor: AppColors.primaryDark,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _listingTypes.add(e.key);
                      } else if (_listingTypes.length > 1) {
                        _listingTypes.remove(e.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_alertEnabled ? '알림 설정 저장' : '알림 끄기'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 위시리스트에 추가하면서 알림 설정도 함께 하는 다이얼로그
class BookAlertQuickSetupDialog extends ConsumerStatefulWidget {
  final String title;
  final String author;
  final String? coverImageUrl;
  final String bookInfoId;

  const BookAlertQuickSetupDialog({
    super.key,
    required this.title,
    required this.author,
    this.coverImageUrl,
    required this.bookInfoId,
  });

  @override
  ConsumerState<BookAlertQuickSetupDialog> createState() =>
      _BookAlertQuickSetupDialogState();
}

class _BookAlertQuickSetupDialogState
    extends ConsumerState<BookAlertQuickSetupDialog> {
  bool _alertEnabled = true;
  final _conditions = {'best', 'good', 'fair'};
  final _listingTypes = {'exchange', 'sale', 'both'};
  static const _conditionLabels = {
    'best': '최상',
    'good': '상',
    'fair': '중',
    'poor': '하',
  };

  static const _listingTypeLabels = {
    'exchange': '교환',
    'sale': '판매',
    'both': '교환+판매',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.notifications_active, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '이 책이 등록되면 알려드릴까요?',
                  style: AppTypography.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.title} - ${widget.author}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('알림 받기'),
            subtitle: const Text('위시리스트에 추가하고 알림을 설정합니다'),
            value: _alertEnabled,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _alertEnabled = v),
          ),

          if (_alertEnabled) ...[
            const Divider(),
            const SizedBox(height: 8),
            Text('책 상태', style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _conditionLabels.entries.map((e) {
                final selected = _conditions.contains(e.key);
                return FilterChip(
                  label: Text(e.value),
                  selected: selected,
                  selectedColor: AppColors.primaryLight.withOpacity(0.3),
                  checkmarkColor: AppColors.primaryDark,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _conditions.add(e.key);
                      } else if (_conditions.length > 1) {
                        _conditions.remove(e.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('거래 유형', style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _listingTypeLabels.entries.map((e) {
                final selected = _listingTypes.contains(e.key);
                return FilterChip(
                  label: Text(e.value),
                  selected: selected,
                  selectedColor: AppColors.primaryLight.withOpacity(0.3),
                  checkmarkColor: AppColors.primaryDark,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _listingTypes.add(e.key);
                      } else if (_listingTypes.length > 1) {
                        _listingTypes.remove(e.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'alertEnabled': _alertEnabled,
                  'preferredConditions': _conditions.toList(),
                  'preferredListingTypes': _listingTypes.toList(),
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(_alertEnabled ? '위시리스트에 추가 + 알림 설정' : '위시리스트에만 추가'),
            ),
          ),
        ],
      ),
    );
  }
}
