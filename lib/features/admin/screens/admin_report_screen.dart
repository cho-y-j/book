import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/admin_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 어드민 신고 관리 화면
/// - 대기 중인 신고 목록 표시
/// - 각 신고: 신고자 UID, 신고 대상 유형, 사유, 날짜
/// - "처리 완료" 버튼으로 처리 메모와 함께 해결
class AdminReportScreen extends ConsumerWidget {
  const AdminReportScreen({super.key});

  String _reasonLabel(String reason) {
    switch (reason) {
      case 'spam':
        return '스팸/광고';
      case 'inappropriate':
        return '부적절한 콘텐츠';
      case 'fraud':
        return '사기/허위 매물';
      case 'harassment':
        return '괴롭힘/욕설';
      case 'copyright':
        return '저작권 침해';
      case 'other':
      default:
        return '기타';
    }
  }

  IconData _reasonIcon(String reason) {
    switch (reason) {
      case 'spam':
        return Icons.campaign_outlined;
      case 'inappropriate':
        return Icons.warning_amber_outlined;
      case 'fraud':
        return Icons.gpp_bad_outlined;
      case 'harassment':
        return Icons.person_off_outlined;
      case 'copyright':
        return Icons.copyright_outlined;
      case 'other':
      default:
        return Icons.flag_outlined;
    }
  }

  String _contentTypeLabel(Map<String, dynamic> report) {
    if (report['reportedBookId'] != null &&
        (report['reportedBookId'] as String).isNotEmpty) {
      return '책 게시물';
    }
    return '사용자';
  }

  void _showResolveDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> report,
  ) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('신고 처리'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '처리 내용을 입력해주세요.',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '처리 메모 (선택사항)',
                hintStyle: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSM),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSM),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final reportId = report['id'] as String;
              final resolution = noteController.text.trim().isEmpty
                  ? '관리자가 처리 완료함'
                  : noteController.text.trim();
              try {
                await ref
                    .read(adminRepositoryProvider)
                    .resolveReport(reportId, resolution);
                ref.invalidate(pendingReportsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('신고가 처리되었습니다'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('처리 실패: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('처리 완료'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(pendingReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('신고 관리')),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: AppDimensions.paddingSM),
              Text(
                '신고 목록을 불러올 수 없습니다',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              TextButton(
                onPressed: () =>
                    ref.invalidate(pendingReportsProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 80, color: AppColors.divider),
                  const SizedBox(height: AppDimensions.paddingMD),
                  Text(
                    '처리할 신고가 없습니다',
                    style: AppTypography.bodyLarge
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pendingReportsProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              itemCount: reports.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.paddingSM),
              itemBuilder: (_, index) {
                final report = reports[index];
                return _ReportCard(
                  report: report,
                  reasonLabel: _reasonLabel(report['reason'] ?? 'other'),
                  reasonIcon: _reasonIcon(report['reason'] ?? 'other'),
                  contentTypeLabel: _contentTypeLabel(report),
                  onResolve: () =>
                      _showResolveDialog(context, ref, report),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final String reasonLabel;
  final IconData reasonIcon;
  final String contentTypeLabel;
  final VoidCallback onResolve;

  const _ReportCard({
    required this.report,
    required this.reasonLabel,
    required this.reasonIcon,
    required this.contentTypeLabel,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = report['createdAt'];
    DateTime? date;
    if (createdAt is Timestamp) {
      date = createdAt.toDate();
    }

    final reporterUid = report['reporterUid'] as String? ?? '';
    final reportedUid = report['reportedUid'] as String? ?? '';
    final description = report['description'] as String?;
    final reportedBookId = report['reportedBookId'] as String?;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: reason icon + label + date ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Icon(reasonIcon,
                      size: AppDimensions.iconSM, color: AppColors.error),
                ),
                const SizedBox(width: AppDimensions.paddingSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reasonLabel, style: AppTypography.titleSmall),
                      Text(
                        '신고 대상: $contentTypeLabel',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                if (date != null)
                  Text(
                    Formatters.timeAgo(date),
                    style: AppTypography.caption,
                  ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingSM),
            const Divider(height: 1),
            const SizedBox(height: AppDimensions.paddingSM),

            // --- Reporter / Reported info ---
            _InfoRow(
              label: '신고자',
              value: reporterUid,
            ),
            _InfoRow(
              label: '피신고자',
              value: reportedUid,
            ),
            if (reportedBookId != null && reportedBookId.isNotEmpty)
              _InfoRow(
                label: '책 ID',
                value: reportedBookId,
              ),

            // --- Description ---
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.paddingSM),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingSM),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Text(
                  description,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textPrimary),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.paddingMD),

            // --- Resolve button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onResolve,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('처리 완료'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingSM + 4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: AppTypography.caption
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
